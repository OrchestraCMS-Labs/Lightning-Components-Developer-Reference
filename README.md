# OrchestraCMS Lightning Components Developer Reference

<!-- MarkdownTOC depth=3 -->

1. [Summary](#summary)
    1. [Compatibility](#compatibility)
    1. [Prerequisites](#prerequisites)
    1. [Deployment](#deployment)
    1. [Configuration](#configuration)
1. [Versioning](#versioning)
    1. [Major Versions](#major-versions)
    1. [Minor Versions](#minor-versions)
    1. [Patch Versions](#patch-versions)

<!-- /MarkdownTOC -->

<a name="summary"></a>
## Summary

This repository contains examples of developing with OrchestraCMS's Lightning Components. It includes
example content types and templates, as well as lightning components for extending and overriding the
functionality provided by OrchestraCMS.

Please see the official documentation on [Stantive Technologies Group's Developer Site](https://developer.stantive.com/Lightning) 
for information on how to use this example code.

<a name="compatibility"></a>
### Compatibility

This code requires a minimum of OrchestraCMS package 8.202 (October 2018, v9.0 Build #8.202).

<a name="prerequisites"></a>
### Prerequisites

1. A compatible version of OrchestraCMS is installed in the target Salesforce organization.
2. A Community using a lightning template (like Customer Service)
3. A site has been created in OrchestraCMS.

<a name="deployment"></a>
### Deployment

1. Deploy the following Lightning Components to the target Salesforce organization
    1. SampleAccordionBody
    2. SampleAccordionTemplate
    3. SampleArticleDetail_Template
    4. SampleArticleSummaryCompact_Template
    5. SampleArticleSummary_Template
    6. SampleContentLoaderBody
    7. SampleContentLoaderSlider
    8. SampleLoadingSpinner
    9. SampleProductDetail
    10. SampleProductSummary
    11. SampleTaxonomyMenuBody
    12. SampleTaxonomyMenuItem 
2. Deploy the following Apex classes to the target Salesforce organization
    1. SampleProductEnhancerController.cls
    2. SampleProductOverrideController.cls
3. Deploy the following Static Resources to the target Salesforce organization
    1. CTCArticleSummaryResource.resource
    2. SampleOverrideCSS.resource

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

<a name="configuration"></a>
### Configuration

Create OrchestraCMS Content Layout records by importing `CTCExport.txt` from the Content Templates
page within the target OrchestraCMS site's setup menu.

Create the following content type(s) and add content templates as indicated.

```
Name: Article
Label: Article
Templates:
    Article Compact, autocreate
    Article Detai, autocreate, default
    Article Summary, autocreate
    CTC Article Summary, autocreate
```

```
Name: FAQ
Label: FAQ
Templates:
    Accordion Section, autocreate, default
```

```
Name: Product
Label: Product
Templates:
    Sample Product Detail, autocreate, default
    Sample Product Summary, autocreate
```

<a name="versioning"></a>
## Versioning

Versions of this content type are numbered MAJOR.MINOR.PATCH.

Any modifications to this code outside of this repository are customizations and will impact upgradeability.

<a name="major-versions"></a>
### Major Versions

Major versions introduce new functionality and may break existing implementations.

<a name="minor-versions"></a>
### Minor Versions

Minor versions introduce new functionality, but will not break existing implementations.

<a name="patch-versions"></a>
### Patch Versions

Patches correct defects in the implementation and do not introduce new functionality.