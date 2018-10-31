global virtual with sharing class SampleProductEnhancerController implements cms.IContentBundlerEnhancer {

    /**
     * Enhance content with extra developer defined properties
     * Add product prices to each piece of content that has a product id
     *
     * @param jsonRequest JSON serialized APIRequest object
     * @param jsonContentBundleList JSON serialized ContentBundleList object
     *
     * @return JSON serialized ContentBundleList object
     */
    global String enhanceContent(String jsonRequest, String jsonContentBundleList) {
        System.debug('SampleProductEnhancerController');

        APIRequest request = (APIRequest) JSON.deserialize(jsonRequest, APIRequest.class);
        ContentBundleList bundleList = (ContentBundleList) JSON.deserialize(jsonContentBundleList, ContentBundleList.class);


        String pricebookName = getValueOrDefault(request.parameters.get('pricebook'), 'Standard');

        bundleList.contentProperties = getProductInfo(bundleList.contentBundles, pricebookName);

        return JSON.serialize(bundleList);
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