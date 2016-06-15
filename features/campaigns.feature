Feature:  Testing the Campaign APIs for DSP.
			They are the following:
				1. Create campaign
				2. Get campaigns by brand name
				3. Update campaign
				4. Get campaign info
				5. Get Users Campaigns List
				6. Get Campaign Details
				
Scenario: API::: save-campaign -> Giving wrong auth key to see if API will create a campaign

Scenario: API::: save-campaign -> Giving correct auth key with no permission to edit to see if API will create a campaign

Scenario: API::: save-campaign -> Giving correct auth key to add basic information to create campaign 

Scenario: API::: compute-media-package and save-campaign -> Giving correct auth key to add basic information to create campaign and use that info to compute media package

Scenario: API::: save-campaign -> Giving correct auth key to add basic information and verify if start date greater than end date is accepted while saving campaign

Scenario: API::: save-campaign -> Giving correct auth key to add basic information without adding end_date and see if campaign is created

Scenario: API::: save-campaign -> 