Feature: Get APIs for DSP
	1. get-languages
	2. get-campaign-objectives
	3. get-all-data
	4. get-product-category
	5. get-audience-type
	6. get-product-sub-category
	7. get-age
	8. get-regions
	9. get-amagi-work
	
Scenario: Checking if get-languages gives correct reponse
Given I want to run DSP APIs
When I run GET for "get-languages"
Then I should see correct response for "get-languages"

Scenario: Checking if adding and deleting new data in get-languages gives correct reponse
Given I want to run DSP APIs
When I add an entry for "language"
And I run GET for "get-languages"
Then I should see correct response for "get-languages"
And I should see "added" data for "language" entry
When I delete an entry for "language"
And I run GET for "get-languages"
Then I should see correct response for "get-languages"
And I should see "deleted" data for "language" entry

Scenario: Checking if get-campaign-objectives gives correct response
Given I want to run DSP APIs
When I run GET for "get-campaign-objectives"
Then I should see correct response for "get-campaign-objectives"

Scenario: Checking if adding and deleting new data in get-campaign-objectives gives correct reponse
Given I want to run DSP APIs
When I add an entry for "campaign_objective"
And I run GET for "get-campaign-objectives"
Then I should see correct response for "get-campaign-objectives"
And I should see "added" data for "campaign_objective" entry
When I delete an entry for "campaign_objective"
And I run GET for "get-campaign-objectives"
Then I should see correct response for "get-campaign-objectives"
And I should see "deleted" data for "campaign_objective" entry

Scenario: Checking if get-all-data gives correct response
Given I want to run DSP APIs
When I run GET for "get-all-data"
Then I should see correct response for "get-all-data"

Scenario: Checking if get-product-category gives correct response
Given I want to run DSP APIs
When I run GET for "get-product-category"
Then I should see correct response for "get-product-category"

Scenario: Checking if adding new data in get-product-category gives correct response
Given I want to run DSP APIs
When I add an entry for "product_category"
And I run GET for "get-product-category"
Then I should see correct response for "get-product-category"
And I should see "added" data for "product_category" entry
When I delete an entry for "product_category"
And I run GET for "get-product-category"
Then I should see correct response for "get-product-category"
And I should see "deleted" data for "product_category" entry

Scenario: Checking if get-audience-type gives correct response
Given I want to run DSP APIs
When I run GET for "get-audience-type"
Then I should see correct response for "get-audience-type"

Scenario: Checking if adding new data in get-audience-type gives correct response
Given I want to run DSP APIs
When I add an entry for "audience_type"
And I run GET for "get-audience-type"
Then I should see correct response for "get-audience-type"
And I should see "added" data for "audience_type" entry
When I delete an entry for "audience_type"
And I run GET for "get-audience-type"
Then I should see correct response for "get-audience-type"
And I should see "deleted" data for "audience_type" entry

Scenario: Checking if get-product-sub-category gives correct response
Given I want to run DSP APIs
When I run GET for "get-product-sub-category"
Then I should see correct response for "get-product-sub-category"

Scenario: Checking if adding new data in get-product-sub-category gives correct response
Given I want to run DSP APIs
When I add an entry for "product_sub_category"
And I run GET for "get-product-sub-category"
Then I should see correct response for "get-product-sub-category"
And I should see "added" data for "product_sub_category" entry
When I delete an entry for "product_sub_category"
And I run GET for "get-product-sub-category"
Then I should see correct response for "get-product-sub-category"
And I should see "deleted" data for "product_sub_category" entry

Scenario: Checking if get-age gives correct response
Given I want to run DSP APIs
When I run GET for "get-age"
Then I should see correct response for "get-age"

Scenario: Checking if adding new data in get-age gives correct response
Given I want to run DSP APIs
When I add an entry for "age"
And I run GET for "get-age"
Then I should see correct response for "get-age"
And I should see "added" data for "age" entry
When I delete an entry for "age"
And I run GET for "get-age"
Then I should see correct response for "get-age"
And I should see "deleted" data for "age" entry

Scenario: Checking if get-regions gives correct response
Given I want to run DSP APIs
When I run GET for "get-regions"
Then I should see correct response for "get-regions"

Scenario: Checking if adding new data in get-regions gives correct response
Given I want to run DSP APIs
When I add an entry for "region"
And I run GET for "get-regions"
Then I should see correct response for "get-regions"
And I should see "added" data for "region" entry
When I delete an entry for "region"
And I run GET for "get-regions"
Then I should see correct response for "get-regions"
And I should see "deleted" data for "region" entry

