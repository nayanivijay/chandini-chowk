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


Scenario: invalid email id for register-guest-user
Scenario: invalid phone number for register-guest-user
Scenario: Register guest user with already existing user


