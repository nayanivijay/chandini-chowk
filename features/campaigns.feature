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
When I "create" campaign with "invalid authorization token"
Then I should see status "401"
And I should see "Un-authorized" message for "save-campaign" API

#Scenario: API::: save-campaign -> Giving correct auth key with no permission to edit to see if API will create a campaign
#Given I want to run DSP APIs
#When I add entry to create new user with "new" data
#And I disallow user to do "/save-campaign"
#And I login with "correct" email and "correct" password
#When I "update" campaign with "valid" authorization token
#Then I should see status ""
#And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving correct auth key to add basic information to create campaign 
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
Then I should see status "201"
And I should see "Campaign saved successfully" message for "save-campaign" API
And I should find the "campaign_id" for the campaign in the "campaigns" collection

Scenario: API::: compute-media-package and save-campaign -> Giving correct auth key to add basic information to create campaign and use that info to compute media package

Scenario: API::: save-campaign -> Giving correct auth key to add basic information and verify if start date greater than end date is accepted while saving campaign
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "invalid start date" 
Then I should see "error"

Scenario: API::: save-campaign -> Giving correct auth key to add basic information without adding end_date and see if campaign is created
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "empty end date" 
Then I should see "error"

Scenario: API::: save-campaign -> Giving different auth key to update an existing campaign and see if API throws error
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token
And I add entry to create new user with "new" data
And I "update" campaign with "new" authorization token
Then I should see "error"

#Then I should see status ""
#And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving missing gender and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "invalid gender"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving invalid audience type and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "invalid audience type"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving invalid age and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "invalid age"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving decimal campaign budget and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "decimal campaign budget"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving end date less than 7 days later and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "small duration"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving end date less than 7 days later and checking if API throws error about missing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "large duration"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving invalid product_category and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "product_category"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving invalid product_sub_category and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "product_sub_category"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving invalid campaign_objective and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "campaign_objective"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: API::: save-campaign -> Giving invalid currency and checking if API validates it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid" authorization token and "currency"
Then I should see status ""
And I should see "" message for "save-campaign" API

Scenario: Add creative for valid campaign id and set true for help_from_amagi
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token" 
And I "create" creative with "help_from_amagi true"
Then I should see success

Scenario: Add creative for valid campaign id and set false for help_from_amagi
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token" 
And I "create" creative with "help_from_amagi false"
Then I should see success

Scenario: Add creative for invalid campaign id
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
And I "create" creative with "invalid campaign id"
Then I should see status ""
And I should see "" message for "save-creative" API

Scenario: Add creative for invalid brand name
Given I want to run DSP APIs
When I add entry to create new user with "new" data 
And I "create" campaign with "valid authorization token"
And I "create" creative with "invalid brand name"
Then I should see status ""
And I should see "" message for "save-creative" API

Scenario: Add creative and then update creative and verify
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
And check if creative is valid
When I "update" creative
Then I should see success
And I should see the changes

Scenario: Add creative and verify and then unlink creative and then verify
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
And check if creative is valid
When I "unlink" creative
Then I should see success
And I should see the changes

Scenario: Invalid creative name for is-valid-creative API should fail
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I do "is-valid-creative" for "invalid creative"
Then I should see "error"

Scenario: Add creative and then verify if creative id exists
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
When I "create" creative with "same creative id"
Then I should see error

Scenario: Add all info and then compute media package
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
When I "compute-media-package" 
Then I should see success
And should show data in "get campaign info"
And should show data in "get campaign details"

Scenario: unlink creative for invalid creative id should fail
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
When I "unlink creative" for "invalid creative id"
Then I should "error"
And should see correct data in "get campaign info"
And should see correct data in "get campaign details"

Scenario: unlink creative for invalid campaign id should fail
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
When I "unlink creative" for "invalid campaign id"
Then I should "error"
And should see correct data in "get campaign info"
And should see correct data in "get campaign details"

Scenario: Get users campaign list and then pick one and get campagin info
Given I want to run DSP APIs
When I add entry to create new user with "new" data 
And I "create" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
And I "create another" campaign with "valid authorization token"
And I "create" creative with "correct info"
Then I should see success
And I should see correct data for "get-users-campaign-list"
And I should see correct data for each campaign

## getting updated package and get-package-cost ##
