({
    getAttributes: function(component, event, helper) {
        return [
            {name: "dateTime", value: component.get('v.dateTime'), valueType: "Text", simple: true},
            {name: "street", value: component.get('v.street'), valueType: "Text"},
            {name: "city", value: component.get('v.city'), valueType: "Text", simple: true},
            {name: "province", value: component.get('v.province'), valueType: "Text", simple: true},
            {name: "postalCode", value: component.get('v.postalCode'), valueType: "Text", simple: true},
            {name: "country", value: component.get('v.country'), valueType: "Text", simple: true}
        ];
    }
})