Feature:  Testing the Campaign APIs for DSP.
			They are the following:
				1. Create campaign
				2. Get campaigns by brand name
				3. Update campaign
				4. Get campaign info
				5. Get Users Campaigns List
				6. Get Campaign Details
				
Scenario: API::: save-campaign -> Giving wrong auth key to see if API will create a campaign
Given I want to run DSP APIs
When I "create" campaign with "invalid" authorization token
Then I should see status "401"
And I should see "Un-authorized" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving correct auth key with no permission to edit to see if API will create a campaign
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I disallow user to do "/save-campaign"
And I login with "correct" email and "correct" password
When I "update" campaign with "valid" authorization token
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving correct auth key to add basic information to create campaign 
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
Then I should see "Campaign saved successfully" message for "save-campaign" API
And I should find the "campaign_id" for the campaign in the "campaigns" collection

Scenario: API::: save-campaign -> Giving correct auth key to add basic information and verify if start date greater than end date is accepted while saving campaign (INVALID TEST CASE)
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid start date" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving correct auth key to add basic information without adding end_date and see if campaign is created (INVALID TEST CASE)
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with empty end date" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving different auth key to update an existing campaign and see if API throws error
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I add entry to create new user with "another new" data
And I "update" campaign with "new" authorization token
Then I should see "Un-authorized" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving missing gender and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid gender" campaign with "valid" authorization token
Then I should see "error"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving invalid audience type and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid audience type" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving invalid age and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid age" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving decimal campaign budget and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with decimal campaign budget" campaign with "valid" authorization token 
Then I should see "error"

Scenario: API::: save-campaign -> Giving end date less than 7 days later and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with small duration" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving end date more than 99 days later and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with large duration" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving invalid product_category and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid product category" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving invalid product_sub_category and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid product sub category" campaign with "valid" authorization token 
Then I should see "error"

Scenario: API::: save-campaign -> Giving invalid campaign_objective and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid campaign objective" campaign with "valid" authorization token
Then I should see "error"

Scenario: API::: save-campaign -> Giving invalid currency and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with invalid currency" campaign with "valid" authorization token
Then I should see "error"

Scenario: Add creative for valid campaign id and set true for help_from_amagi
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "help_from_amagi true"
Then I should see "Creative saved successfully" message for "save-creative" API

Scenario: Add creative for valid campaign id and set false for help_from_amagi
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "help_from_amagi false"
Then I should see "Creative saved successfully" message for "save-creative" API

Scenario: Add creative for invalid campaign id
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "invalid campaign id"
Then I should see "error"
Then I should see status ""
And I should see "" message for "save-creative" API
#
Scenario: Add creative for invalid brand name
Given I want to run DSP APIs
When I add entry to create new user with "new" data 
And I "create" campaign with "valid" authorization token
And I "create" creative with "invalid brand name"
And I should see "error"

Scenario: Create campaign, add creative and then compute media package
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
And I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I compute media package with "correct info"
And I "update" campaign with media package
When I run GET for "get-campaign-cost"
And I should see correct response for "get-campaign-cost"
When I run GET for "get-campaign-transactions"
Then I should see correct response for "get-campaign-transactions"
When I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I run GET for "get-user-stats"
Then I should see correct response for "get-user-stats"
When I run GET for "get-users-campaign-list"
Then I should see correct response for "get-users-campaign-list" API
When I run GET for "get-campaign-state"
Then I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select

Scenario: Create campaign with campaign name given by user and then compute media package
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create edited campaign name" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
And I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I compute media package with "correct info"
And I "update" campaign with media package
When I run GET for "get-campaign-cost"
And I should see correct response for "get-campaign-cost"
When I run GET for "get-campaign-transactions"
Then I should see correct response for "get-campaign-transactions"
When I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I run GET for "get-user-stats"
Then I should see correct response for "get-user-stats"
When I run GET for "get-users-campaign-list"
Then I should see correct response for "get-users-campaign-list" API
When I run GET for "get-campaign-state"
Then I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select

Scenario: Create campaign with already existing campaign name given by user
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create edited existing campaign name" campaign with "valid" authorization token
Then I should see "data false" for "is-valid-campaign-name" API

Scenario: Create campaign without any budget, add creative and then compute media package
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with no campaign budget" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
And I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I compute media package with "correct info"
And I "update" campaign with media package
Then I should verify "playout schedule" 
When I run GET for "get-campaign-cost"
And I should see correct response for "get-campaign-cost"
When I run GET for "get-campaign-transactions"
Then I should see correct response for "get-campaign-transactions"
When I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I run GET for "get-user-stats"
Then I should see correct response for "get-user-stats"
When I run GET for "get-users-campaign-list"
Then I should see correct response for "get-users-campaign-list" API
When I run GET for "get-campaign-state"
Then I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select

Scenario: Create campaign, add creative and then provide less budget and more duration and compute media package
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create with less budget" campaign with "valid" authorization token
And I "create" creative with "high duration"
And I compute media package with "correct info"
Then I should see "error"

Scenario: Add creative and then update creative and verify
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "update" creative with "high duration"
Then I should see success
And I should see the changes

Scenario: Add creative and verify and then unlink creative and then verify
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "create another" creative with "same creative_name"
Then I should see "data false" for "is-valid-creative" API
When I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "unlink" creative with "valid creative id"
Then I should see "Request completed successfully" message for "unlink-creative" API
And I should not see the creative id for the campaign

Scenario: unlink creative for invalid creative id should fail
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "unlink" creative with "invalid creative id"
Then I should see "error"
And I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select


Scenario: unlink creative for invalid campaign id should fail
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "unlink" creative with "invalid campaign id"
Then I should see "error"
And I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select

Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
And I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I compute media package with "correct info"
And I "update" campaign with media package
When I run GET for "get-campaign-cost"
And I should see correct response for "get-campaign-cost"
When I run GET for "get-campaign-transactions"
Then I should see correct response for "get-campaign-transactions"
When I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I run GET for "get-user-stats"
Then I should see correct response for "get-user-stats"
When I run GET for "get-users-campaign-list"
Then I should see correct response for "get-users-campaign-list" API
When I run GET for "get-campaign-state"
Then I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select


Scenario: delete campaign 
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I compute media package with "correct info"
And I "update" campaign with media package
Then I should verify "playout schedule"
When I run GET for "get-campaign-cost"
Then I should see correct response for "get-campaign-cost"
When I run GET for "get-campaign-transactions"
Then I should see correct response for "get-campaign-transactions"
When I run GET for "get-user-stats"
Then I should see correct response for "get-user-stats"
When I run GET for "get-users-campaign-list"
Then I should see correct response for "get-users-campaign-list" API
When I run GET for "get-campaign-state"
Then I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select
When I delete campaign
Then I should see "Campaign deleted successfully" message for "delete-campaign" API
When I run GET for "get-users-campaign-list"
Then I should not find the campaign 

Scenario: Testing APIs::: save-new-package and get-package-cost (Create campaign, add creative, compute media package, add more channels, get updated cost and save-new-package and then check playout schedule and proceed with billing)
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I compute media package with "correct info"
And I "update" campaign with media package
And I run GET for "get-valid-channels"
And I add more channels to the campaign
When I run GET for "get-package-cost"
Then I should see correct response for "get-package-cost"
And I should verify "playout schedule"
When I run GET for "get-campaign-cost"
Then I should see correct response for "get-campaign-cost"
When I run GET for "get-campaign-transactions"
Then I should see correct response for "get-campaign-transactions"
When I run GET for "get-user-stats"
Then I should see correct response for "get-user-stats"
When I run GET for "get-users-campaign-list"
Then I should see correct response for "get-users-campaign-list" API
When I run GET for "get-campaign-state"
Then I should see correct response for "get-campaign-state" API


