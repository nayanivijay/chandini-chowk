# This step is a pre check to see if test is able to connect to server_port and address, database etc

require 'net/http'
require 'mysql'
require 'faker'
require 'test/unit'
require 'test/unit/assertions'
require 'json'
require 'httparty'
require 'unirest'
include Test::Unit::Assertions

@guest_flag=0

Given(/^I want to run DSP APIs$/) do

  puts "Server host: #{$server_host}:#{$port_number}"
  puts "Checking if chandni-chowk is running"

  url="http://#{$server_host}:#{$port_number}"
  puts url
  uri= URI(url)
  Net::HTTP.get(uri)

  puts "Checking if test is able to connect to the database"

  begin
    con=Mysql.new($server_host, $mysql_user, $mysql_password, $db_name)
    puts con.get_server_info
    rs = con.query 'show tables'
    puts "CONNECTED TO DATABASE!!!"
  rescue Mysql::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

####################################
#         Create user API          #
####################################

def data
  ct=["Private","Public"]
  ut=["low-income","high-income"]
  it=["Apparels","Garments","Advertising"]
  @email=Faker::Internet.free_email
  @password=Faker::Internet.password(6,9)
  @name=Faker::Name.name
  @company_name=Faker::Company.name
  @phone=Faker::Number.number(10)
  @company_type=ct.shuffle.sample
  @user_type=ut.shuffle.sample
  @pan_number=Faker::Base.regexify("/[A-Z]{5}[0-9]{4}[A-Z]{1}/")
  @industry_type=it.shuffle.sample
end

When(/^I add entry to create new user with "([^"]*)" data$/) do |type|
  data
  if type == "new" || type == "white spaces email" || type == "alpha name" || type == "another new" || type = nil
    puts "Here"
  elsif type == "same email"
    @email=@email
  elsif type == "invalid email"
    @email=Faker::Base.regexify("/[a-zA-Z0-9]{6}..1@[a-z]{5}.[a-z]{3}/")
  elsif type == "invalid_password"
    @password=Faker::Internet.password(1,5)
  elsif type == "invalid phone"
    @phone=Faker::Base.regexify("/[a-zA-Z0-9]{10}")
  elsif type == "missing_email"
    @email=""
  elsif type == "missing_password"
    @password=""
  elsif type == "missing_name"
    @name=""
  elsif type == "missing_company_name"
    @company_name=""
  elsif type == "missing_phone"
    @phone=""
  elsif type == "missing_company_type"
    @company_type=""
  elsif type == "missing_user_type"
    @user_type=""
  elsif type == "missing_pan_number"
    @pan_number=""
  elsif type == "missing_industry_type"   
    @industry_type=""
  end
  output=`curl -X POST -H "Content-Type: application/json" -d '{
            "email": "#{@email}",
            "password": "#{@password}",
            "name": "#{@name}",
            "company_name": "#{@company_name}",
            "phone": "#{@phone}",
            "company_type": "#{@company_type}",
            "user_type": "#{@user_type}",
            "pan_number": "#{@pan_number}",
            "industry_type": #{@industry_type}" 
            }' "http://#{$server_host}:#{$port_number}/create-user"`
    puts "Printing response from create-user API"
    puts output
    @ans=JSON.parse(output)

  if type == "same new" || type == "invalid phone" || type == "empty password" || type == "empty user type" || type == "missing" || type == "same email" || type == "invalid JSON" || type == "invalid email"
    puts "API should return error"
  else
    @valid_user_token=@ans["data"]["user_token"]
    if type != "another new"
      puts "Storing valid user token"
      @valid_user_token_old=@ans["data"]["user_token"]
      puts @valid_user_token_old
    end
  end
end

Then(/^I should see status "([^"]*)"$/) do |expected_status|
  status=@ans["error"]["status"]
  Test::Unit::Assertions.assert_equal status.to_i, expected_status.to_i
end

Then(/^I should see correct data for "([^"]*)" user$/) do |arg1|
  flag=1
  begin
    con=Mysql.new($server_host, $mysql_user, $mysql_password, $db_name)
    permissions_query="select p.id, p.url, p.name, p.permission_code, ct.content_type from user_role ur inner join role r on ur.role_id=r.id inner join role_permission rp on r.id=rp.role_id  inner join permission p on p.id=rp.permission_id inner join content_type ct on ct.id=p.content_type_id where ur.user_id in (select id from user where email='#{$email}');"
    puts "Executing query:::  #{permissions_query}"
    permissions=con.query(permissions_query)
    permission_rows=permissions.num_rows

    puts "Number of permission rows is #{permission_rows}"
    gen_info_query="select email, name, company_name, phone, state, city, company_type, user_type, active from user where email='#{$email}'"

    puts "Executing query::: #{gen_info_query}"
    gen_info=con.query(gen_info_query)

  rescue Mysql::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end

  info=@ans["data"]
  perm=info["permissions"]

  puts "+++DEBUG+++"
  puts info
  puts perm
  permission_rows.times do 
    ans=permissions.fetch_row
    puts "+++DEBUG+++ rows from database"
    puts ans
    flag=1
    perm.each do |permission|
      if ans[0].to_i == permission["permission_id"].to_i && ans[1] == permission["url"] && ans[2] == permission["name"] && ans[3] == permission["permission_code"] && ans[4] == permission["content_type"]
        flag=0
        puts "Permission code for this row matches!"
      end
    end

    if flag == 1
      puts "Oops no match!"
      break
    end
  end
  geninfo=gen_info.fetch_row
  if geninfo[-1] = 0
    active=false
  else
    active=true
  end
  flag2=1
  puts "General information verification"
  if info["email"] == geninfo[0] && info["name"] == geninfo[1] && info["company_name"] == geninfo[2] && info["phone"] == geninfo[3] && info["state"] == geninfo[4] && info["city"] == geninfo[5] && info["company_type"] == geninfo[6] && info["user_type"] == geninfo[7] && info["active"] == active
    flag2=0
    puts "General info matches"
  end

  Test::Unit::Assertions.assert_equal(flag,0)
  Test::Unit::Assertions.assert_equal(flag2,0)
end

Then(/^I should see "([^"]*)" message for "([^"]*)" API$/) do |expected_message, api|
  if api == "create-user" || ((api == "save-billing-information" || api == "update-billing-information" || api == "edit-user") && expected_message == "Un-authorized") || api == "get-billing-informations" || api == "change-forgot-password"  || ( api == "save-campaign" && expected_message == "Un-authorized" )
    message=@ans["error"]["title"]
    puts "Printing error title: #{message}"
  elsif api == "login" || api == "change-password" || api == "edit-user" || api == "save-billing-information" || api == "delete-billing-information" || api == "update-billing-information" || api == "create-guest-user" || api == "forgot-password" || ( api == "save-campaign" && expected_message == "Campaign saved successfully" ) || api == "save-creative" || api == "unlink-creative" || api == "delete-campaign"
    message=@ans["messages"][0]
  end

  puts message
  puts expected_message
  Test::Unit::Assertions.assert_match message, expected_message
end

####################################
#            login API             #
####################################

When(/^I login with "([^"]*)" email and "([^"]*)" password$/) do |email, password|
     
  if email == "incorrect" 
    @email=Faker::Internet.free_email
  end

  if password == "incorrect"
    @password=Faker::Internet.password(2,8)
  elsif password == "correct with white spaces"
    @password=" "+@password+" "
  end
  
  puts "Checking with response with #{@email} and #{@password}"

  output=`curl -X POST -H "Content-Type: application/json" -d '{
    "email": "#{@email}",
    "password": "#{@password}"
  }' "http://#{$server_host}:#{$port_number}/login"`

  puts "Printing response from API:"
  puts output
  @ans=JSON.parse(output)
 
end

####################################
#      Change password API         #
#################################### 

When(/^I change password for "([^"]*)" email with "([^"]*)" password to "([^"]*)" password$/) do |email_type, old_pass, new_pass|

  if email_type == "invalid"
    @email=Faker::Internet.free_email
  end

  if old_pass == "incorrect"
     @password=Faker::Internet.password(6,8)
  end

  if new_pass == "new valid"
    @new_passwd=Faker::Internet.password(6,8)
  elsif new_pass == "new invalid"
    @new_passwd=Faker::Internet.password(2,5)
  end

  puts "Checking response for change-password API with email: #{@email} 
            old password: #{@password} 
            new password: #{@new_passwd}"

  output=`curl -X POST -H "Content-Type: application/json" -d '{
      "email":"#{@email}",
      "old_password":"#{@password}",
      "new_password":"#{@new_passwd}"
  }' "http://#{$server_host}:#{$port_number}/change-password"`

  puts "Printing response from API:"
  puts output
  @ans=JSON.parse(output)

  if email_type == "valid" && old_pass == "correct" && new_pass == "valid"
    @password=@new_passwd
  end
end

Then(/^I should see "([^"]*)"$/) do |arg1|
  if arg1 == "error"
    if @ans["error"].nil?
      flag=0
    else
      flag=1
    end
  end

  Test::Unit::Assertions.assert_equal 1, flag
end

####################################
#          Edit User API           #
#################################### 

When(/^I edit user with "([^"]*)" /) do |arg1|

  if arg1 == "invalid token"
    @valid_user_token=Faker::Lorem.characters(316)
  end
  if arg1 == "invalid pan"
    @pan_number=Faker::Base.regexify("/[A-Z]{4}[0-9]{5}[A-Z]{2}/")
  end
  if arg1 == "invalid phone"
    @phone=Faker::Base.regexify("/[a-zA-Z0-9]{10}")
  end

  puts "Checking response for edit user:"
  output=`curl -X POST -H "Authorization: #{@valid_user_token}" -H "Content-Type: application/json" -d '{
      "name": "#{@name}",
      "company_name": "#{@company_name}",
      "phone": "#{@phone}",
      "company_type": "#{@company_type}",
      "pan": "#{@pan_number}",
      "industry_type": #{@industry_type}
      }' "http://#{$server_host}:#{$port_number}/edit-user"`  
  puts "Printing response from API:"
  puts output
  @ans=JSON.parse(output)
end

####################################
#          List data API           #
#################################### 

When(/^I run GET for "([^"]*)"$/) do |api|
  
  def getdata(type, data)
  url = "http://#{@server_host}:#{@port_number}/#{type}"
  output=`curl -X GET -H "Authorization: #{@user_token}" -H "Content-Type: application/json" "#{url}"`
  response=JSON.parse(output)
  result=Array.new
  elements=Array.new
  if type == "get-regions" || type == "get-country-state-mappings"
    result=response["data"]
    result.each do |l|
      element=l["#{data}"]
      if !(elements.include? element)
        elements.insert(-1, element)
      end
    end
    return elements
  else
    result=response["data"][data]
    return result
  end
end 

Then(/^I should see correct response for "([^"]*)"$/) do |api|
  
  if api == "get-campaign-objectives"
    key="campaign_objectives"
  elsif api == "get-product-category"
    key="product_category"
  elsif api == "get-product-sub-category"
    key="product_sub_category"
  elsif api == "get-audience-type"
    key="audience_type"
  elsif api == "get-regions"
    key="regions"
  elsif api == "get-age" || api == "get-languages"
    key="channel_mappings"
  elsif api == "get-campaign-cost" 
    key="campaigns"
  elsif api == "get-country-state-mappings"
    key="country_state_mappings"
  elsif api == "get-org-types"
    key="organization_types"
  elsif api == "get-industry-types"
    key="industry_types"
  end

def readmongodata(collection, field)
  mongo_client = Mongo::Client.new($mongo_connect_string)
  list=mongo_client[:"#{collection}"].find.to_a
  elements=Array.new
  list.each do |l|
    element=l["#{field}"]
      if (elements.include? element) == false
        elements.insert(-1, element)
      end
  end
  return elements
end

if (@data1 - @data2).empty?
       @flag=0
     else
       @flag=1
     end
  Test::Unit::Assertions.assert_equal @flag, 0
end

When(/^I add an entry for "([^"]*)"$/) do |arg1|
  mongo_client = Mongo::Client.new($mongo_connect_string)
  
  if arg1 == "language"
    result=mongo_client[:channel_mappings].insert_one({ language: 'Test Language' })
  elsif arg1 == "campaign_objective"
    result = mongo_client[:campaign_objectives].insert_one({ campaign_objectives: 'Test Objective' })
  elsif arg1 == "product_category"
    result = mongo_client[:product_category].insert_one({ product_category: 'Brands - Test Type' })
  elsif arg1 == "audience_type"
    result = mongo_client[:audience_type].insert_one({ audience_type: 'Test Audience' })    
  elsif arg1 == "product_sub_category"
    result = mongo_client[:product_sub_category].insert_one({ product_sub_category: 'Test Sub Category' })
  elsif arg1 == "age"
    result = mongo_client[:channel_mappings].insert_one({ age: '100' })
  elsif arg1 == "region"
    result = mongo_client[:regions].insert_one({ region: "Test Region", type: "Metro", location: "East", contained_in: "N/A" })
  elsif arg1 == "country_state_mappings"
    result = mongo_client[:country_state_mappings].insert_one({ country: "India", state: "Dummy state" })
  elsif arg1 == "organization_types"
    result = mongo_client[:organization_types].insert_one({ organization_type: "Test Organization Type"})
  elsif arg1 == "industry_types"
    result = mongo_client[:industry_types].insert_one({ industry_type: "Test Industry Type"})
  end

  puts result.n
  #Test::Unit::Assertions.assert_equal result.n, 1
end

Then(/^I should see "([^"]*)" data for "([^"]*)" entry$/) do |arg1, arg2|
  flag=0
  puts @data
  if arg2 == "language"
    puts "Checking for language"
    if @data.include? 'Test Language'
      flag=1
    end
  elsif arg2 == "campaign_objective"
    puts "Checking for campaign_objective"
    if @data.include? 'Test Objective'
      flag=1
    end
  elsif arg2 == "product_category"
    puts "Checking for product_category"
    if @data.include? 'Brands - Test Type'
      flag=1
    end
  elsif arg2 == "audience_type"
    puts "Checking for audience_type"
    if @data.include? 'Test Audience'
      flag=1
    end
  elsif arg2 == "product_sub_category"
    puts "Checking for product_sub_category"
    if @data.include? 'Test Sub Category'
      flag=1
    end
  elsif arg2 == "age"
    puts "Checking for age"
    if @data.include? '100'
      flag=1
    end
  elsif arg2 == "country_state_mappings"
    puts "Checking for state"
    @data.each do |data|
      if data["state"]. include? 'Dummy state'
        flag=1
        break
      end
    end
  elsif arg2 == "region"
    puts "Checking for region"
    @data.each do |data|
      if data["region"].include? 'Test Region'
        flag=1
        break
      end
    end
  elsif arg2 == "organization_types"
    puts "Checking for organization type"
    if @data.include? 'Test Organization Type'
      flag=1
    end
  elsif arg2 == "industry_types"
    puts "Checking for industry type"
    if @data.include? 'Test Industry Type'
      flag=1
    end
  end
  
  if arg1 == "added"
    Test::Unit::Assertions.assert_equal flag, 1
  else
    Test::Unit::Assertions.assert_equal flag, 0
  end
end

When(/^I delete an entry for "([^"]*)"$/) do |arg1|
  mongo_client = Mongo::Client.new($mongo_connect_string)

  if arg1 == "language"
    result=mongo_client[:channel_mappings].delete_one({ language: 'Test Language' })
  elsif arg1 == "campaign_objective"
    result = mongo_client[:campaign_objectives].delete_one({ campaign_objectives: 'Test Objective' })
  elsif arg1 == "product_category"
    result = mongo_client[:product_category].delete_one({ product_category: 'Brands - Test Type' })
  elsif arg1 == "audience_type"
    result = mongo_client[:audience_type].delete_one({ audience_type: 'Test Audience' })    
  elsif arg1 == "product_sub_category"
    result = mongo_client[:product_sub_category].delete_one({ product_sub_category: 'Test Sub Category' })
  elsif arg1 == "age"
    result = mongo_client[:channel_mappings].delete_one({ age: '100' })
  elsif arg1 == "region"
    result = mongo_client[:regions].delete_one({ region: "Test Region", type: "Metro", location: "East", contained_in: "N/A" })
  elsif arg1 == "country_state_mappings"
    result = mongo_client[:country_state_mappings].delete_one({ country: "India", state: "Dummy state" })
  elsif arg1 == "organization_types"
    result = mongo_client[:organization_types].delete_one({ organization_type: "Test Organization Type"})
  elsif arg1 == "industry_types"
    result = mongo_client[:industry_types].delete_one({ industry_type: "Test Industry Type"})
  end
    
  Test::Unit::Assertions.assert_equal result.n, 1
end

### Billing apis #####################################################################

When(/^I "([^"]*)" billing info with "([^"]*)"$/) do |operation, type|
  
  @bname=Faker::Name.name
  @bmobile=Faker::Number.number(10)
  @bemail=Faker::Internet.free_email
  @baddress=Faker::Address.street_address
  @bcity=Faker::Address.city
  uri = URI("http://#{$server_host}:#{$port_number}/get-country-state-mappings")
  response = Net::HTTP.get_response(uri)
  ans=JSON.parse(response.body)
  ans=ans["data"].sample
  @bstate=ans["state"]
  @bcountry=ans["country"]
  @user_token = @valid_user_token
  
  if operation == "update" || operation == "delete"
    output=`curl -X GET -H "Authorization: #{@user_token} -H "Content-Type: application/json" 
            "http://#{$server_host}:#{$port_number}/get-billing-informations"`
    @ans=JSON.parse(output)
    @_id=@ans["data"][0]["_id"]
  end
 
  if type == "incorrect _id"
    @_id=Faker::Lorem.characters(24)
  elsif type == "invalid phone"
    @bmobile=Faker::Base.regexify("/[a-zA-Z0-9]{10}")
  elsif type == "invalid email"
    @bemail=Faker::Base.regexify("/[a-zA-Z0-9]{6}..[a-z]@[a-z]{5}.[a-z]{3}")
  elsif type == "invalid user token"
    @user_token=Faker::Lorem.characters(316)
  elsif type == "missing_name"
    @bname=""
  elsif type == "missing_mobile"
    @bmobile=""
   elsif type == "missing_email"
    @bemail=""
  elsif type == "missing_address"
    @baddress=""
  elsif type == "missing_city"
    @bcity=""
  elsif type == "missing_state"
    @bstate=""
  elsif type == "missing_country"
    @bcountry=""
   end

  if operation == "get"
    output=`curl -X GET -H "Authorization: #{@user_token} -H "Content-Type: application/json" 
            "http://#{$server_host}:#{$port_number}/get-billing-informations"`
  elsif operation == "save" || operation == "save another"
    output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
        "name" : "#{@bname}",
        "mobile" : "#{@bmobile}",
        "email" : "#{@bemail}",
        "address" : "#{@baddress}",
        "city" : "#{@bcity}",
        "state" : "#{@bstate}",
        "country" : "#{@bcountry}"
        }' "http://#{$server_host}:#{$port_number}/save-billing-information"`
  elsif operation == "delete"
    output=`curl -X POST -H "Authorization: #{@user_token}" -H "Content-Type: application/json" -d '{
      "_id" : "#{@_id}"
      }' "http://#{$server_host}:#{$port_number}/delete-billing-information"`
  elsif operation == "update"
    output=`curl -X POST -H "Authorization: #{@user_token}" -H "Content-Type: application/json" -d '{
      "_id" : "#{@_id}",
      "name" : "#{@bname}",
      "mobile" : "#{@bphone}",
      "email" : "#{@bemail}",
      "address" : "#{@baddress}",
      "city" : "#{@bcity}",
      "state" : "#{@bstate}",
      "country" : "#{@bcountry}"
        }' "http://#{$server_host}:#{$port_number}/update-billing-information"`
  end
  puts "Printing response from API:"
  puts output
  @ans=JSON.parse(output)
  if operation == "create another"
    @ans_new=@ans
  else
    @ans_old=@ans
  end
end

Then(/^I should "([^"]*)" entry for "([^"]*)"$/) do |arg1, api|
  if api == "get-billing-information" 
    @_id=@ans["data"]
  end

  flag=1
  
  mongo_client=Mongo::Client.new($mongo_connect_string)
  billing=mongo_client[:billing_information]
  list=billing.find.to_a
  list.each do |l|
    id=l["_id"].to_s
    if id == @_id
      puts "_id matched!"
      if l["name"] == @name || l["mobile"] == @phone || ["email"] == @email ||  l["address"] == @address || l["city"] == @city || l["state"] == @state || l["country"] == @country
        flag=0
        break
      end
    end
  end   
  
  if arg1 == "find"
    Test::Unit::Assertions.assert_equal flag, 0
  elsif arg1 == "not find"
    Test::Unit::Assertions.assert_not_equal flag, 0
  end
end

When(/^I "([^"]*)" for "([^"]*)"$/) do |arg1, arg2|
  if arg1 == "forgot password"
    if arg2 == "correct email"
      email=$email
    elsif arg2 == "incorrect email"
      email="chaynika+02@amagi.com"
    end
    puts "Executing: 
          curl -X POST -d '{
          \"email\":\"#{email}\",
          \"target_url\":\"www.google.com/token=\"
          }' \"http://#{$server_host}:#{$port_number}/forgot-password\""
          
    output=`curl -X POST -d '{
      "email":"#{email}",
      "target_url":"www.google.com/token="
      }' "http://#{$server_host}:#{$port_number}/forgot-password"`
    puts output 
    @ans=JSON.parse(output)
    if arg2 == "correct email"
      $token=@ans["data"]
    end
  end 
end

Then(/^"([^"]*)" for "([^"]*)" data should "([^"]*)"$/) do |arg1, arg2, arg3|
  token=$token
  email=$email
  if arg2 == "incorrect token"
    token=Faker::Lorem.characters(40)
  end
  puts "Verifying token.."
  
  puts "Executing: curl -X POST -d '{
                \"token\":\"#{token}\"
                }' \"http://#{$server_host}:#{$port_number}/is-valid-forgot-password-token\""
                
  output=`curl -X POST -d '{
        "token" : "#{token}"
        }' "http://#{$server_host}:#{$port_number}/is-valid-forgot-password-token"`
        
  puts output
  result=JSON.parse(output)
  message=result["messages"][0]
  puts message
  new_password=Faker::Internet.password
  if message == "Valid token" 
    if arg2 == "empty password"
      new_password=""
    end
    puts "Changing password: 
        Executing: curl -X POST -d '{
        \"token\" : \"#{token}\",
        \"new_password\" : \"#{new_password}\"
        }' \"http://#{$server_host}:#{$port_number}/change-forgot-password\""
        
    output=`curl -X POST -d '{
            "token" : "#{token}",
            "new_password" : "#{new_password}"
            }' "http://#{$server_host}:#{$port_number}/change-forgot-password"`
    puts output
    if arg2 == "empty password"
      @ans=JSON.parse(output)
      status=@ans["error"]["status"]
      Test::Unit::Assertions.assert_equal status, 406
    else
      $password=new_password  
    end
  elsif message == "Invalid token" && arg2 == "incorrect token"
    status=result["error"]["status"]
    if arg3 == "not succeed"
      Test::Unit::Assertions.assert_equal status, 401
    end
  end
  
end

################################  CAMPAIGNS AND CREATIVES API ###################################


When(/^I "([^"]*)" campaign with "([^"]*)" authorization token$/) do |action, user_token_type|
  if user_token_type == "valid" || user_token_type == "new"
    user_token=@valid_user_token
    else
      user_token=Faker::Lorem.characters(316)
    end

    if action == "create edited campaign name" 
      @campaign_name="Auto_Campaign"
      puts "Executing:  
              curl -X GET -H \"Content-Type: application/json\" -H \"Authorization: #{@valid_user_token}\" \"http://#{$server_host}:#{$port_number}/is-valid-campaign-name?campaign_name=#{@campaign_name}\""
    
      response=Unirest.get "http://#{$server_host}:#{$port_number}/is-valid-campaign-name?campaign_name=#{@campaign_name}", headers: { "Content-Type" => "application/json", "Authorization" => "#{@valid_user_token}" }
    
      puts response.body
      @resp=response.body["data"]
      puts @resp

      Test::Unit::Assertions.assert_equal @resp, true
    elsif action == "create edited existing campaign name"
      @campaign_name=@campaign_name_old
      puts "Executing:  
              curl -X GET -H \"Content-Type: application/json\" -H \"Authorization: #{@valid_user_token}\" \"http://#{$server_host}:#{$port_number}/is-valid-campaign-name?campaign_name=#{@campaign_name}\""
      
      response=Unirest.get "http://#{$server_host}:#{$port_number}/is-valid-campaign-name?campaign_name=#{@campaign_name}", headers: { "Content-Type" => "application/json", "Authorization" => "#{@valid_user_token}" }
    
      puts response.body
      @resp=response.body["data"]
      puts @resp

      Test::Unit::Assertions.assert_equal @resp, false
    else
      output=`curl -X GET -H "Authorization: #{@valid_user_token}" "http://#{$server_host}:#{$port_number}/get-campaign-name"`
      output=JSON.parse(output)
      @campaign_name=output["data"]
      puts @campaign_name
      @campaign_name_old=@campaign_name
    end

    @brand_name=Faker::Company.name

    mongo_client = Mongo::Client.new($mongo_connect_string)

    if action == "create with invalid product category"
      @product_category=Faker::Lorem.word
    else
      product_cat_list=mongo_client[:product_category].find.to_a
      product_cat_arr=Array.new
      product_cat_list.each do |row|
        element=row["product_category"]
        product_cat_arr.insert(-1, element)
      end

      @product_category=product_cat_arr.sample
    end
      
    if action == "create with invalid product sub category"
      @product_sub_category=Faker::Lorem.word
    else
      product_sub_cat_list=mongo_client[:product_sub_category].find.to_a
      product_sub_cat_arr=Array.new
      product_sub_cat_list.each do |row|
        element=row["product_sub_category"]
        product_sub_cat_arr.insert(-1, element)
      end

      @product_sub_category=product_sub_cat_arr.sample
    end

    if action == "create with invalid campaign objective"
      @campaign_objective=Faker::Lorem.word
    else
      campaign_objective_list=mongo_client[:campaign_objectives].find.to_a
      camp_obj_arr=Array.new
      campaign_objective_list.each do |row|
        element=row["campaign_objectives"]
        camp_obj_arr.insert(-1, element)
      end

      @campaign_objective=camp_obj_arr.sample
    end

    if action == "create with invalid currency"
      @currency=Faker::Lorem.word
    else
      @currency="INR"
    end

    if action == "create with decimal campaign budget"
      @lakh=Faker::Number.between(0,99)
      @thousand=Faker::Number.between(0,99)
    elsif action == "create with no campaign budget"
      @lakh=""
      @thousand=""
    elsif action == "create with less budget"
      @lakh=0
      @thousand=Faker::Number.number(1)
    else
      @lakh=Faker::Number.between(0,99)
      @thousand=Faker::Number.between(0,99)
    end

    @campaign_budget=(@lakh.to_i*100000)+(@thousand.to_i*1000)
    if action == "create with invalid start date"
      @campaign_start_date=(DateTime.now-10).strftime("%Y-%m-%dT%H:%m:%S.%L%z")
    else
      @campaign_start_date=(DateTime.now+10).strftime("%Y-%m-%dT%H:%m:%S.%L%z")
    end
    if action == "create with small duration"
      @duration=Faker::Number.between(0,6)
    elsif action == "create with large duration"
      @duration=Faker::Number.between(100,200)
    else
      @duration=Faker::Number.between(7,15)
    end

    if action == "create with invalid gender"
      @gender=Faker::Lorem.word
    else
      @gender="Male"
    end

    if action == "create with invalid age"
      @age=Faker::Lorem.word
    else
      @age="15-30"
    end
    if action == "create with invalid audience type"
      @audience_type=Faker::Lorem.word
    else
      @audience_type="Urban"
    end
    @geography="Bangalore"
    @creative_format="Video"
    if action == "create edited existing campaign name"
      assert("Campaign should not be created!")
    elsif action == "update"
      puts "Executing the following:"
      puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
      \"_id\" : #{@campaign_id},
      \"campaign_settings\": {
        \"campaign_name\": \"#{@campaign_name}\",
        \"brand_name\": \"#{@brand_name}\",
        \"product_category\": \"#{@product_category}\",
        \"product_sub_category\": \"#{@product_sub_category}\",
        \"campaign_objective\": \"#{@campaign_objective}\",
        \"gender\": [\"#{@gender}\"],
        \"age\": [\"#{@age}\"],
        \"audience_type\": [\"#{@audience_type}\"],
        \"geography\": [\"#{@geography}\"],
        \"creative_format\": [\"#{@creative_format}\"],
        \"currency\": \"#{@currency}\",
        \"lakh\": #{@lakh},
        \"thousand\": #{@thousand},
        \"campaign_start_date\": \"#{@campaign_start_date}\",
        \"duration\": #{@duration}
      }
      }' \"http://#{$server_host}:#{$port_number}/save-campaign\""

      output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{ 
              "_id": #{@campaign_id}, 
              "campaign_settings": {
                "campaign_name": "#{@campaign_name}",
                "brand_name": "#{@brand_name}",
                "product_category": "#{@product_category}",
                "product_sub_category": "#{@product_sub_category}",
                "campaign_objective": "#{@campaign_objective}",
                "gender": ["#{@gender}"],
                "age": ["#{@age}"],
                "audience_type": ["#{@audience_type}"],
                "geography": ["#{@geography}"],
                "creative_format": ["#{@creative_format}"],
                "currency": "#{@currency}",
                "lakh": #{@lakh},
                "thousand": #{@thousand},
                "campaign_start_date": "#{@campaign_start_date}",
                "duration": #{@duration}
              }
              }' "http://#{$server_host}:#{$port_number}/save-campaign"`
    elsif action == "create with no campaign budget"
      output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{"campaign_settings": {"campaign_name": "#{@campaign_name}","brand_name": "#{@brand_name}","product_category": "#{@product_category}","product_sub_category": "#{@product_sub_category}","campaign_objective": "#{@campaign_objective}","gender": ["#{@gender}"],"age": ["#{@age}"],"audience_type": ["#{@audience_type}"],"geography": ["#{@geography}"],"creative_format": ["#{@creative_format}"],"currency": "#{@currency}","campaign_start_date": "#{@campaign_start_date}","duration": #{@duration}}}' "http://#{$server_host}:#{$port_number}/save-campaign"`
    else
      puts "Executing the following:"
      puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
      \"campaign_settings\": {
        \"campaign_name\": \"#{@campaign_name}\",
        \"brand_name\": \"#{@brand_name}\",
        \"product_category\": \"#{@product_category}\",
        \"product_sub_category\": \"#{@product_sub_category}\",
        \"campaign_objective\": \"#{@campaign_objective}\",
        \"gender\": [\"#{@gender}\"],
        \"age\": [\"#{@age}\"],
        \"audience_type\": [\"#{@audience_type}\"],
        \"geography\": [\"#{@geography}\"],
        \"creative_format\": [\"#{@creative_format}\"],
        \"currency\": \"#{@currency}\",
        \"lakh\": #{@lakh},
        \"thousand\": #{@thousand},
        \"campaign_start_date\": \"#{@campaign_start_date}\",
        \"duration\": #{@duration}
      }
      }' \"http://#{$server_host}:#{$port_number}/save-campaign\""


      output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{"campaign_settings": {"campaign_name": "#{@campaign_name}","brand_name": "#{@brand_name}","product_category": "#{@product_category}","product_sub_category": "#{@product_sub_category}","campaign_objective": "#{@campaign_objective}","gender": ["#{@gender}"],"age": ["#{@age}"],"audience_type": ["#{@audience_type}"],"geography": ["#{@geography}"],"creative_format": ["#{@creative_format}"],"currency": "#{@currency}", "thousand": #{@thousand}, "lakh": #{@lakh}, "campaign_start_date": "#{@campaign_start_date}","duration": #{@duration}}}' "http://#{$server_host}:#{$port_number}/save-campaign"`
    end

    if action != "create edited existing campaign name"
      puts "Printing response from API:"
      puts output
      @ans=JSON.parse(output)

      if @ans["status"].to_i == 0
        @campaign_id=@ans["data"]["campaign_id"]
      end
    end
end


When(/^I disallow user to do "([^"]*)"$/) do |permission|
  find_id_query="select id from permission where url='/#{permission}'"
  puts "Executing query::: #{find_id_query}"
  begin
    con=Mysql.new($server_host, $mysql_user, $mysql_password, $db_name)
    perm_id=con.query(find_id_query)
    id=perm_id.fetch_row[0]

    puts "Disabling permissions for the role"
    delete_query="delete from role_permission where permission_id='#{id}'"
    puts "Executing query::: #{delete_query}"
    con.query(delete_query)
  rescue Mysql::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

Then(/^I should find the "([^"]*)" for the campaign in the "([^"]*)" collection$/) do |arg1, collection_name|
  if collection_name == "campaigns" 
    campaign_id=@ans["data"]["campaign_id"].to_i
    puts "Campaign id is #{campaign_id}"
    mongo_client = Mongo::Client.new($mongo_connect_string)
    campaigns_arr=mongo_client[:campaigns].find.to_a
    flag=1
    campaigns_arr.each do |campaign|
      puts "Campaign is #{campaign}"
      camp_id=campaign["_id"].to_json 
      camp_id=camp_id.to_i   
      puts camp_id
      #camp_id=JSON.parse(camp_id_json).values[0]
      #puts camp_id_json
      if camp_id == campaign_id
        flag=0
        puts "Match!"
        break
      end
    end
  end
  Test::Unit::Assertions.assert_equal flag, 0
end

When(/^I "([^"]*)" campaign with "([^"]*)" authorization token and "([^"]*)"$/) do |action, user_token_type, type|
  if user_token_type == "valid"
    user_token=@valid_user_token
  else
    user_token=Faker::Lorem.characters(316)
  end

  if type == "invalid gender" || type == "invalid audience type"
    gender=Faker::Lorem.word
  elsif type == "invalid age"
    age=Faker::Number.number(2)
  elsif type == "decimal campaign budget"
    campaign_budget=Faker::Number(6, 2)
  elsif type == "small duration"
    duration=Faker::Number.between(0,6)
  elsif type == "large duration"
    duration=Faker::Number.between(100,500)
  elsif type == "product_category"
    product_category=Faker::Company.catch_phrase
  elsif type == "product_sub_category"
    product_sub_category=Faker::Company.buzzword
  elsif type == "campaign_objective"
    campaign_objective=Faker::Company.bs
  elsif type == "currency"
    currency=Faker::Hacker.abbreviation
  end

end

When(/^I "([^"]*)" creative with "([^"]*)"$/) do |action, type|
  puts @valid_user_token
  if type == "invalid campaign id"
    associated_with_campaigns=@campaign_id-1
  else
    associated_with_campaigns=@campaign_id
  end

  if action == "create" || action == "create another" 
    if type != "same creative_name"
      @creative_name=Faker::Lorem.word
    end

    if type == "help_from_amagi false"
      help_from_amagi=false
    else
      help_from_amagi=true
    end

    if type == "amagi_should_edit false"
      amagi_should_edit=false
    else
      amagi_should_edit=true
    end

    if type == "invalid brand name"
      brand_name=Faker::Company.name
      brand_name=brand_name[0,4]
    else
      brand_name=@brand_name[0,4]
    end

    url="http://#{$server_host}:#{$port_number}/get-creative-price"
    uri=URI(url)
    response=Net::HTTP.get(uri)
    response=JSON.parse(response)
    puts response
    response=response["data"]
    creative_duration=response.sample["duration"]
    puts creative_duration
    response.each do |r|
      puts "==="
      puts r["duration"]
      if r["duration"] == creative_duration
        puts "Match"
        @creative_fee=r["price"]
        puts @creative_fee
        break
      end
    end

    creative_format=@creative_format
    creative_brief=Faker::Hipster.sentence

    puts "Checking if creative name is valid for the user:
          curl -X GET -H \"Authorization: #{@valid_user_token}\" -H \"Content-Type: application/json\" \"http://#{$server_host}:#{$port_number}/is-valid-creative?creative_name=  #{@creative_name}\""


    puts "Unirest.get \"http://#{$server_host}:#{$port_number}/is-valid-creative?creative_name=  #{@creative_name}\", headers: { \"Content-Type\" => \"application/json\", \"Authorization\" => \"#{@valid_user_token}\" }"
    response=Unirest.get "http://#{$server_host}:#{$port_number}/is-valid-creative?creative_name=  #{@creative_name}", headers: { "Content-Type" => "application/json", "Authorization" => "#{@valid_user_token}" }
    #response=Unirest.get "http://#{$server_host}:#{$port_number}/is-valid-creative?creative_name=  #{creative_name}", headers: { "Content-Type" => "application/json", "Authorization" => "#{@valid_user_token}" }

    puts response.body
    @resp=response.body["data"]
    puts @resp
    if @resp == true
      flag=1
    else
      flag=0
    end

    if type == "same creative_name"
      assert_equal flag,0
    else
      assert_equal flag, 1
  
      puts "Creative name #{@creative_name} is valid"
    
      puts "Executing the following:
            curl -X POST -H \"Authorization: #{@valid_user_token}\" -H \"Content-Type: application/json\" -d '[{
                \"creative_name\": \"#{@creative_name}\",
                \"creative_duration\": \"#{creative_duration}\",
                \"creative_format\": \"#{creative_format}\",
                \"help_from_amagi\": #{help_from_amagi},
                \"creative_fee\": #{@creative_fee},
                \"creative_brief\": \"#{creative_brief}\",
                \"creative_language\": \"EN\",
                \"amagi_should_edit\": #{amagi_should_edit},
                \"associated_with_campaigns\": [#{associated_with_campaigns}]
                }]' \"http://#{$server_host}:#{$port_number}/save-creative?prefix=#{brand_name}\""

      output=`curl -X POST -H "Authorization: #{@valid_user_token}" -H "Content-Type: application/json" -d '[{ "creative_name": "#{@creative_name}", "creative_duration": "#{creative_duration}", "creative_format": "#{creative_format}", "creative_language": "EN", "help_from_amagi": #{help_from_amagi},  "creative_fee": #{@creative_fee}, "creative_brief": "#{creative_brief}", "amagi_should_edit": #{amagi_should_edit}, "associated_with_campaigns": [#{associated_with_campaigns}] }]' "http://#{$server_host}:#{$port_number}/save-creative?prefix=#{brand_name}"` 
      #{}, "creative_duration": "#{creative_duration}", "creative_format": "#{creative_format}", "creative_language": "EN", "help_from_amagi": #{help_from_amagi},  "creative_fee": #{creative_fee}, "creative_brief": #{amagi_should_edit}, "associated_with_campaigns": [#{associated_with_campaigns}] }]' "http://#{$server_host}:#{$port_number}/save-creative?prefix=#{brand_name}"`
      #output=Unirest.post "http://#{$server_host}:#{$port_number}/save-creative?prefix=#{brand_name}", 
       #             headers: { "Content-Type" => "application/json", "Authorization" => "#{@valid_user_token}" }, 
        #            parameters:{ :creative_name => "#{creative_name}", :creative_duration => "#{creative_duration}", :creative_format => "#{creative_format}", 
        #             :help_from_amagi => help_from_amagi, :creative_fee => creative_fee, :creative_brief => "#{creative_brief}", :creative_language => "EN", 
        #             :amagi_should_edit => amagi_should_edit, :associated_with_campaigns => [associated_with_campaigns] 

      if action == "create"
        $spot_duration=creative_duration.to_i
      else
        $spot_duration=$spot_duration+creative_duration.to_i
      end

      puts "Spot duration is #{$spot_duration}"
      puts output
      puts "Printing response from API:"
      @ans=JSON.parse(output)
      @created_id=@ans["data"]["created_ids"][0]
    end
  elsif action == "unlink"
    if type == "valid creative id"
      creative_id=@ans["data"]["created_ids"][0]
    else
      creative_id=Faker::Lorem.word
    end
    puts "Executing the following: 
          curl -X POST -H \"Content-Type: application/json\" -H \"Authorization: #{@valid_user_token}\" -d '[{
              \"_id\" : \"#{creative_id}\",
              \"associated_with_campaigns\": [#{associated_with_campaigns}]
          }]' \"http://#{$server_host}:#{$port_number}/unlink-creative\""

    #output=`curl -X POST -H "Content-Type: application/json" -H "Authorization: #{@valid_user_token}" -d '[{ "_id" : "#{creative_id}", "associated_with_campaigns": ["#{associated_with_campaigns}"] }]' "http://#{$server_host}:#{$port_number}/unlink-creative"`
    puts creative_id
    puts associated_with_campaigns
    output=`curl -X POST -H "Content-Type: application/json" -H "Authorization: #{@valid_user_token}" -d '[{"_id" : "#{creative_id}",  "associated_with_campaigns": [#{associated_with_campaigns}] }]' "http://#{$server_host}:#{$port_number}/unlink-creative"`

    puts output
    puts "Printing response from API:"
    @ans=JSON.parse(output)
  end
  
end

Then(/^I should see "([^"]*)" for "([^"]*)" API$/) do |arg1, arg2|
  flag=1
  if arg2 == "is-valid-creative" || arg2 == "is-valid-campaign-name"
    if arg1 == "data false"
      if @resp != false
        flag=1
      else
        flag=0
      end
    elsif arg1 == "data true"
      if @resp != true
        flag=1
      else
        flag=0
      end
    end
  end

  assert_equal flag, 0
end

When(/^I compute media package with "([^"]*)"$/) do |arg1|
  if arg1 == "correct info"
    puts "Executing the following:
          curl -X POST -H \"Content-Type: application/json\" -d '{
          \"age\":[\"#{@age}\"],
          \"gender\":[\"#{@gender}\"],
          \"region\":[\"#{@geography}\"],
          \"budget\":\"#{@campaign_budget}\",
          \"spot_duration\":\"#{$spot_duration}\",
          \"duration\": \"#{@duration}\"
          }' \"http://#{$server_host}:#{$port_number}/compute-media-package\""


    #output=Unirest.post "http://#{$server_host}:#{$port_number}/compute-media-package",
     #     headers: { "Content-Type" => "application/json" },
    #      parameters: { :age => "#{@age}", :gender => ["#{@gender}"], :region => ["#{@geography}"], :budget => "#{@campaign_budget}",
    #                  :spot_duration => "#{$spot_duration}", "duration" => "#{@duration}" }

    #puts output.body
    #url="http://#{$server_host}:#{$port_number}/compute-media-package"
    #uri=URI(url)
    #res=Net::HTTP.post_form(uri, 'age' => '#{@age}', 'gender' => '["#{@gender}"]', 'region' => '["#{@geography}"]', 'budget' => '#{@campaign_budget}',
                      #'spot_duration' => '#{$spot_duration}', 'duration' => '#{@duration}')
    #res.content_type = 'application/json'
    #puts res.body

    output=`curl -X POST -H "Content-Type: application/json" -d '{
          "age":["#{@age}"],
          "gender":["#{@gender}"],
          "region":["#{@geography}"],
          "budget":"#{@campaign_budget}",
          "spot_duration":"#{$spot_duration}",
          "duration": "#{@duration}"
          }' "http://#{$server_host}:#{$port_number}/compute-media-package"`

    @ans=JSON.parse(output)
    puts "Printing data for media package"
    media_package=@ans["data"]
    puts media_package
    @media_package=media_package.to_json
  end
end

When(/^I "([^"]*)" campaign with media package$/) do |arg1|
  if arg1 == "update"
    puts "Media package is: #{@media_package}"
    puts "curl -X POST -H \"Authorization: #{@valid_user_token}\" -H \"Content-Type: application/json\" -d ' 
            { \"_id\" : #{@campaign_id}, \"media_plan_tv\" : #{@media_package}
            }' \"http://#{$server_host}:#{$port_number}/save-campaign\""
    output=`curl -X POST -H "Authorization: #{@valid_user_token}" -H "Content-Type: application/json" -d ' 
            { "_id" : #{@campaign_id}, "media_plan_tv" : #{@media_package}
            }' "http://#{$server_host}:#{$port_number}/save-campaign"`

    puts output
  end
end

Then(/^it should show me campaign details for every campaign I select$/) do
  puts "Response from get-campaign-state API is"
  puts @data
  @data.each do |row|
    campaign_id=row["_id"]
    puts campaign_id
    output=`curl -X GET -H "Authorization: #{@valid_user_token}" -H "Content-Type: application/json" "http://#{$server_host}:#{$port_number}/get-campaign-details?campaign_id=#{campaign_id}"`
    puts output
  end
end

Then(/^I should see correct response for "([^"]*)" API$/) do |api|
  if api == "get-users-campaign-list" || api == "get-campaign-state"
    key="campaigns"
  end

  mongo_client = Mongo::Client.new($mongo_connect_string)

  list = mongo_client[:campaigns].find.to_a
  flag=0
  if api == "get-users-campaign-list" || api == "get-campaign-state"
    @data.each do |l|
      list.each do |d|
        if (l["_id"] == d["_id"]) 
          if api == "get-users-campaign-list"
            if (l["brand_name"] == d["campaign_settings"]["brand_name"]) && (l["campaign_name"] == d["campaign_settings"]["campaign_name"]) && (l["campaign_status"] == d["campaign_status"]) && (l["spot_duration"] == d["media_plan_tv"]["package"]["spot_duration"].to_i)
              puts "Found match"
              flag=1
            else
              flag=0
            end
            break
          elsif api == "get-campaign-state"
            if l["campaign_status"] == d["campaign_status"]
              puts "Found match"
              flag=1
            else
              flag=0
            end
            break
          end
        end
      end
      if flag == 0
          break
      end
    end
  end

  assert_equal flag, 1
end

Then(/^I should not see the creative id for the campaign$/) do
  puts "Printing campaign details for campaign ID #{@campaign_id}:"
  output=`curl -X GET -H "Authorization: #{@valid_user_token}" -H "Content-Type: application/json" "http://#{$server_host}:#{$port_number}/get-campaign-details?campaign_id=#{@campaign_id}"`
  puts output

  @ans=JSON.parse(output)
  associated_creatives=@ans["data"]["campaign_details"]["associated_creatives"][0]
  puts @created_id
  puts associated_creatives
  flag=0
  if associated_creatives.include? @created_id
    flag=1
  end

  assert_equal flag, 0
end

When(/^I delete campaign$/) do
  puts "Deleting campaign ID: #{@campaign_id}"

  output=`curl -X GET -H "Authorization: #{@valid_user_token}" "http://#{$server_host}:#{$port_number}/delete-campaign?campaign_id=#{@campaign_id}"`
  puts output

  @ans=JSON.parse(output)
end

Then(/^I should not find the campaign$/) do
  puts @ans
  match=1
  if @ans["data"].include? @campaign_id
    puts "Campaign ID found. UNEXPECTED!"
  else
    puts "Campaign ID not found. Campaign deleted!"
    match=0
  end

  assert_equal match, 0
end


############################
# STEPS FOR following APIs:
#     1. Guest-user
############################

def data
  @email=Faker::Internet.free_email
  @password=Faker::Internet.password(6,9)
  @name=Faker::Name.name
  @company_name=Faker::Company.name
  @phone=Faker::Number.number(10)
  @company_type=getdata("get-org-types", "organization_type")
  @user_type=getdata("get-audience-type","audience_type")
  @pan_number=Faker::Base.regexify("/[A-Z]{5}[0-9]{4}[A-Z]{1}/")
  @industry_type=getdata("get-industry-types","industry_type")
end

When(/^I add entry to create new user with "([^"]*)" data$/) do |type|
  data
  if type == "new" 
    puts "Here"
  elsif type == "same_email"
    @email=@email
  elsif type == "invalid_email"
    @email=Faker::Base.regexify("/[a-zA-Z0-9]{6}..[a-z]@[a-z]{5}.[a-z]{3}")
  elsif type == "invalid_password"
    @password=Faker::Internet.password(1,5)
  elsif type == "invalid_phone"
    @phone=Faker::Base.regexify("/[a-zA-Z0-9]{10}")
  elsif type == "invalid pan_number"
    @pan_number=Faker::Base.regexify("/[A-Z0-9a-z]{5}[A-Z]{4}[0-9]{1}/")
  elsif type == "missing_email"
    @email=""
  elsif type == "missing_password"
    @password=""
  elsif type == "missing_name"
    @name=""
  elsif type == "missing_company_name"
    @company_name=""
  elsif type == "missing_phone"
    @phone=""
  elsif type == "missing_company_type"
    @company_type=""
  elsif type == "missing_user_type"
    @user_type=""
  elsif type == "missing_pan_number"
    @pan_number=""
  elsif type == "missing_industry_type"
    @industry_type=""



  

def getdata(type, data)
  url = "http://#{@server_host}:#{@port_number}/#{type}"
  output=`curl -X GET -H "Authorization: #{@user_token}" -H "Content-Type: application/json" "#{url}"`
  response=JSON.parse(output)
  if type == "get-regions" || type == "get-country-state-mappings"
    result=response["data"].sample
    result=result[data]
  else
    result=response["data"][data].sample
  end
  return result
end 

def getdata(type, data)
  url = "http://#{@server_host}:#{@port_number}/#{type}"
  output=`curl -X GET -H "Authorization: #{@user_token}" -H "Content-Type: application/json" "#{url}"`
  response=JSON.parse(output)
  if type == "get-regions" || type == "get-country-state-mappings"
    result=response["data"].sample
    result=result[data]
  else
    result=response["data"][data].sample
  end
  return result
end 
  
def readmongodata(collection, field)
  mongo_client = Mongo::Client.new($mongo_connect_string)
  list=mongo_client[:"#{collection}"].find.to_a
  elements=Array.new
  list.each do |l|
    element=l["#{field}"]
      if !elements.include? element
        elements.insert(-1, element)
      end
  end
  return elements
end
    
   