({
    changeTaxonomyPath: function(component, event, helper) {
        // notify all linked components that the taxonomy path has changed
        var taxClickedEvt = $A.get('e.cms:TaxonomyPathChangeEvt');

        taxClickedEvt.setParams({
            tagPath: component.get('v.tagPath'),
            instanceName: component.get('v.instanceName')
        }).fire();

        component.set('v.isActive', true);
    }
})