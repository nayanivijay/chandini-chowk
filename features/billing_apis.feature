Feature: Testing the Billing APIs:
	1. Get billing info
	2. Delete billing info
	3. Save billing info
	4. Update billing info
	
Scenario: Adding billing info for a user and getting billing info to see if it has been saved and then delete it and verify that it has been deleted
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
And I should "find" entry for "get-billing-information"
When I "delete" billing info with "correct _id"
And I should see "billing information deleted successfully" message for "delete-billing-information" API
And I should "not find" entry for "get-billing-information"


Scenario: Adding billing info for a user with incomplete information
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "incomplete info"
Then I should see "error"

Scenario: Adding billing info for a user with invalid city and check if code verifies it
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "invalid city"
Then I should see "error"

Scenario: Adding billing info for a user and checking if invalid phone no format is accepted
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "invalid phone"
Then I should see "error"

Scenario: Adding billing info for a user and checking if invalid email format is accepted
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "invalid email"
Then I should see "error"

Scenario: Get billing info for invalid/expired user token
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "invalid user token"
Then I should see status "401"
And I should see "Un-authorized" message for "save-billing-information" API

Scenario: Add multiple billing info for a particular user and check if it gets all the billing info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
And I "create another" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
And I should "find both" entry for "get-billing-information"

Scenario: Add multiple billing info and delete one billing info and verify the other exists
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I "create another" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
And I should "find both" entry for "get-billing-information"
When I "delete" billing info with "correct _id" 
And I should see "billing information deleted successfully" message for "delete-billing-information" API
And I should "not find" entry for "get-billing-information"
And I should "find one" entry for "get-billing-information"

Scenario: Update billing information for an invalid _id
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "update" billing info with "incorrect _id"
Then I should see "error"

Scenario: Update billing information for an invalid user token
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "update" billing info with "invalid user token"
And I should see "Un-authorized" message for "update-billing-information" API

Scenario: Update billing information for a user with incomplete information
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I "update" billing info with "incomplete info"
Then I should see "error"

Scenario: Update billing info for a user with invalid city
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I "update" billing info with "invalid city"
Then I should see "error"

Scenario: Update billing info for a user with invalid phone no
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I "update" billing info with "invalid phone"
Then I should see "error"

Scenario: Update billing info for a user with invalid email format
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I "update" billing info with "invalid email"
Then I should see "error"

Scenario: Update billing info with valid info
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I "update" billing info with "correct info"
And I should see "billing information updated successfully" message for "update-billing-information" API

Scenario: Create billing information as one user and edit the billing information as another user
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I add entry to create new user with "another new" data
And I "create" billing info with "correct info"
Then I should see "billing information saved successfully" message for "save-billing-information" API
And I "update" billing info with "old token"
Then I should see "error"

Scenario: Create billing information as one user and delete the billing information as another user
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I add entry to create new user with "another new" data
And I "create" billing info with "correct info"
Then I should see "billing information saved successfully" message for "save-billing-information" API
And I "delete" billing info with "old token"
Then I should see "error"

