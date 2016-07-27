Feature: Guest user flow
	
Scenario: Guest user flow default and then register user and then check if campaign is saved and then check if able to accesss settings and transactions, register that user and then the campaign should be saved for that user
Given I want to run DSP APIs
When I want to "proceed" as guest user
Then I should see "Account created successfully" message for "create-guest-user" API
When I "create" billing info with "correct info"
Then I should see status "401"
And I should see "Un-authorized" message for "save-billing-information" API
When I run GET for "get-billing-informations"
Then I should see status "401"
And I should see "Un-authorized" message for "get-billing-informations" API
When I edit user with "valid" user token
Then I should see status "401"
And I should see "Un-authorized" message for "edit-user" API
When I "create" campaign with "valid" authorization token
And I "create" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
And I "create another" creative with "correct info"
Then I should see "Creative saved successfully" message for "save-creative" API
When I compute media package with "correct info"
And I "update" campaign with media package
When I run GET for "get-campaign-cost"
When I run GET for "get-campaign-transactions"
When I want to "register" as guest user
Then I should see "Account created successfully" message for "create-guest-user" API
When I "create" billing info with "correct info"
And I should see "billing information saved successfully" message for "save-billing-information" API
When I run GET for "get-user-stats"
#Then I should see correct response for "get-user-stats"
When I run GET for "get-users-campaign-list"
Then I should see correct response for "get-users-campaign-list" API
When I run GET for "get-campaign-state"
Then I should see correct response for "get-campaign-state" API
And it should show me campaign details for every campaign I select


Scenario: invalid email id for register-guest-user
Given I want to run DSP APIs
When I want to "proceed" as guest user
Then I should see "Account created successfully" message for "create-guest-user" API
When I add entry to register guest user with "invalid email" data
Then I should see "error"

Scenario: invalid phone number for register-guest-user
Given I want to run DSP APIs
When I want to "proceed" as guest user
Then I should see "Account created successfully" message for "create-guest-user" API
When I add entry to register guest user with "invalid phone" data
Then I should see "error"

Scenario: Register guest user with already existing user
Given I want to run DSP APIs
When I add entry to create new user with "new" data
Then I should see correct data for "given" user
When I want to "proceed" as guest user
Then I should see "Account created successfully" message for "create-guest-user" API
When I want to "register" as guest user
Then I should see "error"



