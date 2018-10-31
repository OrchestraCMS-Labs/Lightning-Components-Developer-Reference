global virtual with sharing class SampleProductOverrideController implements cms.IContentBundlerOverride {

    /**
     * Completely override default functionality and perform your own server side logic
     * Developer is responsible any OrchestraCMS API requests they may need for
     * building a ContentBundleList
     * ContentProperties may also be returned with the ContentBundleList as with
     * the EnhancerController. Override and Enhancer controllers may be used in
     * conjunction with each other. The Enhancer controller will be run after the Override
     * controller.
     *
     * @param jsonRequest JSON serialized APIRequest object
     *
     * @return JSON serialized ContentBundleList object
     */
    global String getContent(String jsonRequest) {
        System.debug('SampleProductOverrideController');

        APIRequest request = (APIRequest) JSON.deserialize(jsonRequest, APIRequest.class);

        String pricebookName = getValueOrDefault(request.parameters.get('pricebook'), 'Standard');
        List<String> contentTypes = request.listParameters.get('contentTypes');
        List<String> tagPaths = request.listParameters.get('tagPaths');
        List<String> originIds = request.listParameters.get('originIds');
        Integer limitCount = getValueOrDefault(request.parameters.get('limitCount'), 5);
        Integer depth = getValueOrDefault(request.parameters.get('depth'), 5);
        Integer offset = getValueOrDefault(request.parameters.get('offset'), 0);
        Boolean isTargeted = request.requestFlags.get('isTargeted');
        String order = getValueOrDefault(request.parameters.get('order'), 'date');

        RenderingAPIRequest renderingRequest = new RenderingAPIRequest();

        // determine by which method content is going to be rendered
        if (originIds != null && originIds.size() > 0) {
            renderingRequest.parameters.put('renderType', 'originId');
            renderingRequest.listParameters.put('originIds', originIds);
            renderingRequest.listParameters.put('contentLayouts', new List<String> {
                'JsonDataTemplate'
            });

        } else if (tagPaths != null && tagPaths.size() > 0) {
            renderingRequest.parameters.put('renderType', 'taxonomy');
            renderingRequest.listParameters.put('tagPaths', tagPaths);
            List<List<String>> contentLayoutsList = new List<List<String>>();
            for (Integer i = 0; i < depth; i++) {
                contentLayoutsList.add(new List<String> {
                    'JsonDataTemplate'
                });
            }
            renderingRequest.layoutsForTaxonomy = contentLayoutsList;
            renderingRequest.listParameters.put('contentTypes', contentTypes);
            renderingRequest.parameters.put('limit', String.valueOf(limitCount));
            renderingRequest.parameters.put('offset', String.valueOf(offset));
            renderingRequest.parameters.put('order', order);

        } else {
            renderingRequest.parameters.put('renderType', 'contentType');
            renderingRequest.listParameters.put('contentLayouts', new List<String> {
                'JsonDataTemplate'
            });
            renderingRequest.listParameters.put('contentTypes', contentTypes);
            renderingRequest.parameters.put('limit', String.valueOf(limitCount));
            renderingRequest.parameters.put('offset', String.valueOf(offset));
            renderingRequest.parameters.put('order', order);

        }

        renderingRequest.requestFlags.put('targeted', isTargeted);
        renderingRequest.requestFlags.put(RenderingAPIRequest.WITH_SOCIAL_BUNDLE, false);

        Map<String, String> apiParams = buildRequest(renderingRequest);
        ContentBundleList bundleList = makeRequest(apiParams);
        bundleList.contentProperties = getProductInfo(bundleList.contentBundles, pricebookName);

        return JSON.serialize(bundleList);
    }


    /**
     * Build the OrchestraCMS RenderingAPI request
     *
     * @param renderingRequest
     *
     * @return api request map
     */
    private Map<String, String> buildRequest(RenderingAPIRequest renderingRequest) {
        Map<String, String> apiParams = new Map<String, String>();
        apiParams.put('service', 'OrchestraRenderingAPI');
        apiParams.put('action', 'getRenderedContent');
        apiParams.put('apiVersion', '4.0');
        apiParams.put('runtime', 'Sites');
        apiParams.put('renderingRequest', JSON.serialize(renderingRequest));

        return apiParams;
    }

    /**
     * Perform an OrchestraCMS RenderingAPI request
     *
     * @param apiParams api request map
     *
     * @return contentBundleList containing contentBundles and optionally socialBundles (depending on request parameters)
     */
    private ContentBundleList makeRequest(Map<String, String> apiParams) {
        String response = cms.ServiceEndPoint.doActionApex(apiParams);
        JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) JSON.deserialize(response, JSONMessage.APIResponse.class);
        RenderResultBundle resultBundle = (RenderResultBundle) JSON.deserialize(apiResponse.responseObject, RenderResultBundle.class);

        List<ContentBundle> contentBundles = new List<ContentBundle>();
        Map<String, SocialBundle> socialBundles = new Map<String, SocialBundle>();
        for (RenderResultBundle.RenderedContent renderedContent : resultBundle.renderings) {
            String serializedContentBundle = renderedContent.renderMap.get('JsonDataTemplate');
            ContentBundle cb = (ContentBundle) JSON.deserialize(serializedContentBundle, ContentBundle.class);

            contentBundles.add(cb);

            if (renderedContent.socialBundle != null) {
                socialBundles.put(cb.originId, renderedContent.socialBundle);
            }
        }

        return new ContentBundleList(contentBundles, socialBundles, resultBundle.contentRemaining);
    }

    private class ProductInfo {
        public String price;
    }

    /**
     * Query for product prices based on a list of content and a pricebook name.
     * This code should not be taken as the definitive way of working with pricebooks
     *
     * @param contentBundles list of orchestraCMS content bundles. this content should have an attribute called "productId" that holds a valid Product2 recordid
     * @param pricebookName the name of a valid pricebook
     *
     * @return a mapping of content origin id to json serialized ProductInfo object
     */
    private Map<String, String> getProductInfo(List<ContentBundle> contentBundles, String pricebookName) {
        // get product price for each piece of content returned
        Map<Id, Id> productMap = new Map<Id, Id>();
        Map<String, String> contentProperties = new Map<String, String>();
        for (ContentBundle bundle : contentBundles) {
            List<AttributeBundle.ContentAttribute> attributes = bundle.contentAttributes.get('en_US');
            for (AttributeBundle.ContentAttribute attr : attributes) {
                if (attr.name == 'productId') {
                    productMap.put(attr.value, bundle.originId);
                    break;
                }
            }
        }
        if (productMap.keySet().size() > 0) {
            String priceBookId = [SELECT Id FROM Pricebook2 WHERE Name = :pricebookName LIMIT 1].Id;
            List<PricebookEntry> pbes = [SELECT UnitPrice, Product2Id FROM PricebookEntry
                WHERE Pricebook2Id = :priceBookId AND Product2Id IN :productMap.keySet() AND Product2.IsActive = true];

            for (PricebookEntry entry : pbes) {
                ProductInfo pi = new ProductInfo();
                pi.price = '$' + entry.UnitPrice;
                contentProperties.put(productMap.get(entry.Product2Id), JSON.serialize(pi));
            }
        }

        return contentProperties;
    }

    /**
     * Return the provided value in Integer form if valid, otherwise return the default value.
     *
     * @param stringValue a user provided integer value
     * @param defaultValue the default value to use when no valid value is provided
     */
    private Integer getValueOrDefault(String stringValue, Integer defaultValue) {
        Integer value = defaultValue;
        try {
            value = Integer.valueOf(stringValue);
        } catch(Exception e) {}

        return value;
    }

    /**
     * Return the provided value, unless it is blank in which case the default value is returned
     *
     * @param stringValue the user provided value to use
     * @param defaultValue the default value to use when no valid value is provided
     */
    private String getValueOrDefault(String stringValue, String defaultValue) {
        return String.isNotBlank(stringValue) ? stringValue : defaultValue;
    }

}