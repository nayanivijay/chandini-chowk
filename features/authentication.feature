Feature:  Testing the Authentication APIs for DSP
	  They are the following: 
		1. Create Acc
		2. Login
		3. Edit user
		4. Change forgot password
		5. Change Password	
	  Some more APIs :
	    6. Forgot password
		7. Is valid token

Scenario: API::: create-user -> Giving all entries for create-user to create a new user and checking if it returns SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "new" data
Then I should see correct data for "given" user

Scenario: API::: create-user -> Giving all entries for create-user to create a new user with already existing data and checking if it does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I add entry to create new user with "same new" data
Then I should see status "200"
And I should see "Request completed successfully" message for "create-user" API

Scenario: API::: create-user -> Giving all entries for create-user to create a new user with already existing email id but different details if does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I add entry to create new user with "same email" data
Then I should see status "200"
And I should see "Request completed successfully" message for "create-user" API

Scenario: API::: create-user -> Giving missing entries for create-user to create a new user and checking if it does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "missing" data
Then I should see status "400"
And I should see "Bad request" message for "create-user" API

Scenario: API::: create-user -> Giving incorrect format of JSON for create-user to create a new user and checking if it does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "invalid JSON" data
Then I should see status "500"
And I should see "Internal Server Error" message for "create-user" API

Scenario: API::: create-user -> Given incorrect format of email address for create-user to create a new user and checking if it does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "invalid email" data
Then I should see status "400"
And I should see "Bad request" message for "create-user" API

Scenario: API::: create-user -> Given incorrect format of phone number for create-user to create a new user and checking if it does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "invalid phone" data
Then I should see status "400"
And I should see "Bad request" message for "create-user" API

Scenario: API::: create-user -> Given empty password for create-user to create a new user and checking if it does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "empty password" data
Then I should see status "406"
And I should see "Not Acceptable" message for "create-user" API

#Scenario: API::: create-user -> Given empty user_type for create-user to create a new user and checking if it does NOT return SUCCESS (INVALID TEST CASE)
#Given I want to run DSP APIs
#When I add entry to create new user with "empty user_type" data
#Then I should see status "406"
#And I should see "Not Acceptable" message for "create-user" API

Scenario: API::: create-user -> Given invalid company_type for create-user to create a new user and checking if it does NOT return SUCCESS
Given I want to run DSP APIs
When I add entry to create new user with "invalid company_type" data
Then I should see status "406"
And I should see "Not Acceptable" message for "create-user" API

Scenario: API::: create-user -> Given white spaces in email id for create-user to create a new user and checking if it returns SUCCESS (it should trim the white spaces)
Given I want to run DSP APIs
When I add entry to create new user with "white spaces email" data
Then I should see correct data for "new" user

Scenario: API::: login -> Giving correct entries for login and password, the user should be able to successfully login
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I login with "correct" email and "correct" password
Then I should see "Login successfull" message for "login" API
And I should see correct data for "given" user

Scenario: API::: login -> Giving incorrect password for valid email, the user should not be able to log in
Given I want to run DSP APIs
When I add entry to create new user with "new" data
When I login with "correct" email and "incorrect" password
Then I should see status "200"
And I should see "Wrong password" message for "login" API

Scenario: API::: login -> Giving invalid email, the user should not be able to log in
Given I want to run DSP APIs
When I login with "incorrect" email and "incorrect" password
Then I should see status "200"
And I should see "User does not exist" message for "login" API

Scenario: API::: login -> Giving correct password with white spaces for valid email, the user should not be able to log in
Given I want to run DSP APIs
When I add entry to create new user with "new" data
When I login with "correct" email and "correct with white spaces" password
Then I should see status "200"
And I should see "Wrong password" message for "login" API


### change-password API ###
#
Scenario: API::: change-password -> Giving correct password and valid email and changing password to incorrect format should NOT succeed
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I change password for "valid" email with "correct" password to "new invalid" password
Then I should see "error"

Scenario: API::: change-password -> Giving invalid email and password for change-password API
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I change password for "invalid" email with "correct" password to "new valid" password
Then I should see status "200"
And I should see "User does not exist" message for "change-password" API

Scenario: API::: change-password -> Giving valid email and incorrect password for change-password API
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I change password for "valid" email with "incorrect" password to "new valid" password
Then I should see status "200"
And I should see "Wrong password" message for "change-password" API

Scenario: API::: change-password -> Giving valid email and correct password for change-password API
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I change password for "valid" email with "correct" password to "new valid" password
Then I should see "Change Password Successfull" message for "change-password" API
When I login with "correct" email and "correct" password
Then I should see "Login successfull" message for "login" API
And I should see correct data for "given" user


#### edit-user API ###

Scenario: API::: edit-user -> Giving invalid user token and editing user should NOT be allowed
Given I want to run DSP APIs
When I edit user with "invalid" user token 
Then I should see status "401"
And I should see "Invalid token" message for "edit-user" API

Scenario: API::: edit-user -> Giving valid user token and editing user should be allowed
Given I want to run DSP APIs
When I add entry to create new user with "new" data
When I edit user with "valid" user token
Then I should see "Saved successfully" message for "edit-user" API

Scenario: API::: edit-user -> Giving valid user token and editing user with few missing information should NOT be allowed
Given I want to run DSP APIs
When I add entry to create new user with "new" data
When I edit user with "valid missing" user token
Then I should see "Saved successfully" message for "edit-user" API

Scenario: API::: edit-user -> Giving valid user token and editing user with few empty fields should NOT be allowed
Given I want to run DSP APIs
When I add entry to create new user with "new" data
When I edit user with "valid empty" user token
Then I should see "error"
Then I should see "Saved successfully" message for "edit-user" API

Scenario: API::: edit-user -> Checking if editing email id and changing it to an email id of another existing user is accepted (FUTURE TEST CASE)
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I edit user with "existing" email
Then I should see "error"

Scenario: API::: edit-user -> Checking if invalid pan throws error
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I edit user with "invalid pan and valid" user token
Then I should see "error"

Scenario: API::: forgot-password -> Giving correct email id for login
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "forgot password" for "correct email"
Then "change-forgot-password" for "new" data should "succeed"
When I login with "correct" email and "correct" password
Then I should see "Login successfull" message for "login" API
And I should see correct data for "given" user

Scenario: API::: forgot-password -> Giving incorrect email id for forgot password 
Given I want to run DSP APIs
When I "forgot password" for "incorrect email"
Then I should see status "200"
And I should see "User does not exist" message for "forgot-password" API

Scenario: API::: forgot-password -> Giving correct email id and invalid token
Given I want to run DSP APIs
When I "forgot password" for "correct email"
Then "change-forgot-password" for "incorrect token" data should "not succeed"

Scenario: API::: forgot-password -> Giving correct email id but empty new password
Given I want to run DSP APIs
When I add entry to create new user with "new" data
And I "forgot password" for "correct email"
Then "change-forgot-password" for "empty password" data should "not succeed"
And I should see "Not Acceptable" message for "change-forgot-password" API
 


