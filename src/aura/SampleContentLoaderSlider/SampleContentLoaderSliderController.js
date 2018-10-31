({
    doInit: function(component, event, helper) {

        $A.createComponent(
            'cms:ContentLoader',
            {
                contentType: component.get('v.contentType'),
                contentLayout: component.get('v.contentLayout'),
                tagPath: component.get('v.tagPath'),
                depth: component.get('v.depth'),
                order: component.get('v.order'),
                ignoreTargets: component.get('v.ignoreTargets'),
                limitCount: component.get('v.limitCount'),
                showLoadMore: false,
                displayDetail: component.get('v.displayDetail'),
                customDetail: component.get('v.customDetail'),
                displayUnreadStatus: component.get('v.displayUnreadStatus'),
                displayLikeButton: component.get('v.displayLikeButton'),
                displayChatterFeed: component.get('v.displayChatterFeed'),
                instanceName: component.get('v.instanceName'),
                siteName: component.get('v.siteName'),
                overrideLoadingComponent: 'c:SampleLoadingSpinner',
                // developerOverrideString: '{"loadingComponent":"c:SampleLoadingSpinner"}'
            },
            function (newCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.contentLoader', newCmp);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);

                    component.set('v.overrideComponentName', null);
                }
            }
        );

    },

    componentLoaded: function(component, event, helper) {
        // Only act on events sent from our content loader. This event is also fired when loading the detail view of inline content
        if (event.getSource().getGlobalId() === component.get('v.contentLoader').getGlobalId()) {
            helper.setupComponent(component, event, helper);
        }
    },

    refresh: function(component, event, helper) {
        var contentLoader = component.get('v.contentLoader');
        contentLoader.reInit();
    },

    scrollLeft: function(component, event, helper) {
        helper.advanceSlides(component, helper, -1);
    },

    scrollRight: function(component, event, helper) {
        helper.advanceSlides(component, helper, 1);
    }
})