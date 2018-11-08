({
    getAttributes: function(component, event, helper) {
        return [
            {name: "Headline", value: component.get('v.Headline'), valueType: "Text", simple: true},
            {name: "SummaryContent", value: component.get('v.SummaryContent'), valueType: "Text"},
            {name: "HTMLContent", value: component.get('v.HTMLContent'), valueType: "RichText"},
            {name: "ImageId", value: component.get('v.ImageId'), valueType: "Link"},
            {name: "LargeImageId", value: component.get('v.LargeImageId'), valueType: "Link"},
            {name: "TitleImageText", value: component.get('v.TitleImageText'), valueType: "Text"}
        ];
    }
})