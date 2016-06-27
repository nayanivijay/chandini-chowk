# This step is a pre check to see if test is able to connect to server_port and address, database etc

require 'net/http'
require 'mysql'
require 'faker'
require 'test/unit'
require 'test/unit/assertions'
require 'json'
require 'net/http'
require 'httparty'
include Test::Unit::Assertions

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

############################
# STEPS FOR following APIs:
#     1. create-user API
############################


When(/^I add entry to create new user with "([^"]*)" data$/) do |type|
  if type == "new" || type == "white spaces email" || type == "alpha name" || type == "another new"
    puts "Here"
  	$name=Faker::Name.name
  	#$last_name=Faker::Name.last_name
  	#if type == "alpha name"
  	#	$last_name="O'\Neil"
  	#end
  	$company_name=Faker::Company.name
  	$phone="9999999999"
  	$company_type="agency"
  	$user_type="user"
    if type == "another new"
      puts "Here too"
      $email="chaynika+02@amagi.com"
    else
  	 $email="chaynika+01@amagi.com"
    end
  	$password=Faker::Internet.password
  elsif type == "same new"
  	name=$name
  	#last_name=$last_name
  	company_name=$company_name
  	phone=$phone
  	company_type=$company_type
  	user_type=$user_type
  	email=$email
  	password=$password
  elsif type == "same email"
  	name=Faker::Name.name
  	#last_name=Faker::Name.last_name
  	company_name=Faker::Company.name
  	phone="9999999999"
  	company_type="sme"
  	user_type="user"
  	email=$email
  	password=Faker::Internet.password
  elsif type == "missing"
  	name=Faker::Name.name
  	#last_name=Faker::Name.last_name
  	company_name=Faker::Company.name
  	phone=Faker::Number.number(10)
  	company_type=""
  	user_type="user"
  	email="chaynika+01@amagi.com"
  	password=Faker::Internet.password
  elsif type == "invalid email"
  	o=[('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
  	d=[('a'..'z')].map { |i| i.to_a }.flatten
  	usr=(0...8).map { o[rand(o.length)] }.join
  	domain=(0...5).map { d[rand(d.length)] }.join
  	email=usr+'..aa@'+domain+'.com'
  	name=$name
  	#last_name=$last_name
  	company_name=$company_name
  	phone=$phone
  	company_type=$company_type
  	user_type=$user_type
  	password=$password
  elsif type == "invalid phone" || type == "invalid company_type"
  	name=Faker::Name.name
  	#last_name=Faker::Name.last_name
  	company_name=Faker::Company.name
  	user_type="user"
  	phone="9999999999"
  	email="chaynika+01@amagi.com"
  	company_type="agency"
  	if type == "invalid phone"
  		p=[('0'..'9'), ('a'..'z')].map { |i| i.to_a }.flatten
  		phone=(0...10).map { p[rand(p.length)] }.join
  	else
  		company_type=Faker::Hacker.verb
  	end
  	password=Faker::Internet.password
  elsif type.include? "empty"
  	name=Faker::Name.name
  	#last_name=Faker::Name.last_name
  	company_name="sme"
  	phone="9999999999"
  	company_type="agency"
  	user_type="user"
  	email="chaynika+01@amagi.com"
  	password=Faker::Internet.password
  	if type == "empty password"
  		password=""
  	elsif type == "empty user_type"
  		user_type=""
  	end
  end

  if type == "invalid JSON"
  	email="chaynika+01@amagi.com"
  	puts "Executing:"
  	puts "Printing a wrong format of JSON"
  	puts "curl -X POST -H \"Content-Type: application/json\" -d '{
	\"email\": \"#{email}\",
	\"password\": \"#{$password}\",
	\"name\": \"#{$name}\",
	\"company_name\": \"#{$company_name}\"
	\"phone\": \"#{$phone}\",
	\"company_type\": \"#{$company_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "#{email}",
	"password": "#{$password}",
	"name": "#{$name}",
	"company_name": "#{$company_name}"
	"phone": "#{$phone}",
	"company_type": "#{$company_type}",
	"user_type": "#{user_type}"
	}' "http://#{$server_host}:#{$port_number}/create-user"`
  elsif type == "new" || type == "alpha name" || type == "another new"
  	puts "Executing:"
  	puts "curl -X POST -H \"Content-Type: application/json\" -d '{
	\"email\": \"#{$email}\",
	\"password\": \"#{$password}\",
	\"name\": \"#{$name}\",
	\"company_name\": \"#{$company_name}\",
	\"phone\": \"#{$phone}\",
	\"company_type\": \"#{$company_type}\",
	\"user_type\": \"#{$user_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "#{$email}",
	"password": "#{$password}",
	"name": "#{$name}",
	"company_name": "#{$company_name}",
	"phone": "#{$phone}",
	"company_type": "#{$company_type}",
	"user_type": "#{$user_type}"
	}' "http://#{$server_host}:#{$port_number}/create-user"`
  elsif type == "white spaces email"
  	 puts "Executing:"
  	puts "curl -X POST -H \"Content-Type: application/json\" -d '{
	\"email\": \"  #{$email}\",
	\"password\": \"#{$password}\",
	\"name\": \"#{$name}\",
	\"company_name\": \"#{$company_name}\",
	\"phone\": \"#{$phone}\",
	\"company_type\": \"#{$company_type}\",
	\"user_type\": \"#{$user_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "  #{$email}",
	"password": "#{$password}",
	"name": "#{$name}",
	"company_name": "#{$company_name}",
	"phone": "#{$phone}",
	"company_type": "#{$company_type}",
	"user_type": "#{$user_type}"
	}' "http://#{$server_host}:#{$port_number}/create-user"`
  else
  	puts "Executing:"
  	puts "curl -X POST -H \"Content-Type: application/json\" -d '{
	\"email\": \"#{email}\",
	\"password\": \"#{password}\",
	\"name\": \"#{name}\",
	\"company_name\": \"#{company_name}\",
	\"phone\": \"#{phone}\",
	\"company_type\": \"#{company_type}\",
	\"user_type\": \"#{user_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "#{email}",
	"password": "#{password}",
	"name": "#{name}",
	"company_name": "#{company_name}",
	"phone": "#{phone}",
	"company_type": "#{company_type}",
	"user_type": "#{user_type}"
	}' "http://#{$server_host}:#{$port_number}/create-user"`
  end
  puts "Printing response from create-user API"
  puts output
  @ans=JSON.parse(output)
  if type == "same new" || type == "invalid phone" || type == "empty password" || type == "empty user type" || type == "missing" || type == "same email" || type == "invalid JSON" || type == "invalid email"
    puts "API should return error"
  else
    @valid_user_token=@ans["data"]["user_token"]
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
  if api == "create-user"	|| ((api == "save-billing-information" || api == "update-billing-information") && expected_message == "Un-authorized") || api == "change-forgot-password"  || ( api == "save-campaign" && expected_message == "Un-authorized" )
  	message=@ans["error"]["title"]
  	puts "Printing error title: #{message}"
  elsif api == "login" || api == "change-password" || api == "edit-user" || api == "save-billing-information" || api == "delete-billing-information" || api == "update-billing-information" || api == "forgot-password" || ( api == "save-campaign" && expected_message == "Campaign saved successfully" )
    message=@ans["messages"][0]
  end

  puts message
  puts expected_message
  Test::Unit::Assertions.assert_match message, expected_message
end

####################################
#STEPS USED FOR:
# 1. login API
####################################

When(/^I login with "([^"]*)" email and "([^"]*)" password$/) do |arg1, arg2|
	if arg1 == "correct"
		email=$email
	elsif arg1 == "incorrect"
		email="chaynika+01@amagi.com"
	end

	if arg2 == "correct"
		password=$password
	elsif arg2 == "incorrect"
		password=Faker::Internet.password
	elsif arg2 == "correct with white spaces"
		password=" "+$password
	end

	puts "Checking with response with #{email} and #{password}"

	output=`curl -X POST -H "Content-Type: application/json" -d '{
    "email": "#{email}",
    "password": "#{password}"
	}' "http://#{$server_host}:#{$port_number}/login"`

	puts "Printing response from API:"
	puts output
	@ans=JSON.parse(output)
  
  if arg2 == "correct"
    @valid_user_token=@ans["data"]["user_token"]
  end
end

###############################
# STEPS USED FOR:
# 1. change-password API
###############################

When(/^I change password for "([^"]*)" email with "([^"]*)" password to "([^"]*)" password$/) do |email_type, pswd_type, new_pass|
  if email_type == "valid"
  	email=$email
  elsif email_type == "invalid"
  	email="chaynika+02@amagi.com"
  end

  if pswd_type == "correct"
  	password=$password
  elsif pswd_type == "incorrect"
  	password=Faker::Internet.password
  end

  if new_pass == "new valid"
  	new_passwd=Faker::Internet.password
  elsif new_pass == "new invalid"
  	new_passwd=" "
  end

  $password=new_passwd

  puts "Checking response for change-password API with email: #{email} 
  					old password: #{password} 
  					new password: #{new_passwd}"

  puts "Executing the following:"
  puts "curl -X POST -H \"Content-Type: application/json\" -d '{
  		\"email\":\"#{email}\",
  		\"old_password\":\"#{password}\",
  		\"new_password\":\"#{new_passwd}\"
  }' \"http://#{$server_host}:#{$port_number}/change-password\"`"
  output=`curl -X POST -H "Content-Type: application/json" -d '{
  		"email":"#{email}",
  		"old_password":"#{password}",
  		"new_password":"#{new_passwd}"
  }' "http://#{$server_host}:#{$port_number}/change-password"`

  puts "Printing response from API:"
  puts output
  @ans=JSON.parse(output)
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

### edit-user API

When(/^I edit user with "([^"]*)" email$/) do |arg1|
  if arg1 == "existing"
    new_email="monodeep@amagi.com"
  end
  new_name=Faker::Name.name
  #new_last_name=Faker::Name.last_name
  new_comp_name=Faker::Company.name
  new_phone=Faker::Number.number(11)
  new_comp_type="agency"
  new_state="KA"
  new_city=Faker::Address.city
  user_token=@valid_user_token
  
	output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
		"name": "#{name}",
		"company_name": "#{new_comp_name}",
		"company_type": "#{new_comp_type}",
		"email": "#{new_email}",
		"state": "#{new_state}",
		"city": "#{new_city}"
		}' "http://#{$server_host}:#{$port_number}/edit-user"`
  
  puts "Printing response from API:"
  puts output
  @ans=JSON.parse(output)  
end

When(/^I edit user with "([^"]*)" user token$/) do |arg1|

puts "CHANGE CODE AND REMOVE CITY AND STATE AND PUT PAN NO INSTEAD!!!"
  if arg1 == "valid" || arg1 == "valid missing" || arg1 == "valid empty"
  	user_token=@valid_user_token
  elsif arg1 == "invalid"
  	user_token=Faker::Lorem.characters(316)
  end

  new_name=Faker::Name.name
  #new_last_name=Faker::Name.last_name
  new_comp_name=Faker::Company.name
  new_phone=Faker::Number.number(11)
  new_comp_type="agency"
  new_state="KA"
  new_city=Faker::Address.city
  new_email="chaynika+02@amagi.com"

  if arg1 == "valid empty"
  	name=""
  	new_phone=""
  end

  puts "Executing the following:"

  if arg1 == "valid" || arg1 == "valid empty"
  	puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
  		\"name\": \"#{new_name}\",
  		\"company_name\": \"#{new_comp_name}\",
  		\"company_type\": \"#{new_comp_type}\",
  		\"email\": \"#{new_email}\",
  		\"state\": \"#{new_state}\",
  		\"city\": \"#{new_city}\"
  		}' \"http://#{$server_host}:#{$port_number}/edit-user\""

  	output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
  		"name": "#{new_name}",
  		"company_name": "#{new_comp_name}",
  		"company_type": "#{new_comp_type}",
  		"email": "#{new_email}",
  		"state": "#{new_state}",
  		"city": "#{new_city}"
  		}' "http://#{$server_host}:#{$port_number}/edit-user"`
  else
  	puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
  		\"name\": \"#{new_name}\",
  		\"city\": \"#{new_city}\"
  		}' \"http://#{$server_host}:#{$port_number}/edit-user\""
  	output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
  		"name": "#{new_name}",
  		}' "http://#{$server_host}:#{$port_number}/edit-user"`
  end		
  puts "Printing response from API:"
  puts output
  @ans=JSON.parse(output)
end

When(/^I run GET for "([^"]*)"$/) do |api|
  url="http://#{$server_host}:#{$port_number}/#{api}"
  puts url
  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  @api_status=response.code
  response=JSON.parse(response.body)
  if api == "get-regions" || api == "get-all-data"
    @data=response["data"]
  elsif api == "get-age"
    @data=response["data"]["age"]
  elsif api == "get-languages"
    @data=response["data"]["language"]
  else
    @data=response["data"].values.to_a
  end
  puts "=========================================================================="
  puts @data
  puts "=========================================================================="
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
  end
  
  mongo_client = Mongo::Client.new($mongo_connect_string)

  if api == "get-all-data"
    keys=@data.keys
    puts keys
    keys.each do |item|
      from_json=@data["#{item}"]
      arr_elements=Array.new
      puts from_json
      
      if item == "age" || item == "language"
        list=mongo_client[:channel_mappings].find.to_a
        list.each do |a|
          ans=a["#{item}"]
          if (arr_elements.include? ans) == false
            arr_elements.insert(-1,ans)
          end
        end
      elsif item == "audience_type" || item == "product_sub_category" || item == "campaign_objectives" || item == "product_sub_category"
        list=mongo_client[:"#{item}"].find.to_a
        arr_elements=Array.new
        list.each do |l|
           element=l["#{item}"]
           arr_elements.insert(-1, element)
        end
      end
      puts arr_elements
      if (arr_elements - from_json).empty?
        @flag=0
        puts "Match found for #{item}"
      else
        @flag=1
        puts "No match for #{item}"
        break
      end  
    end
  else
    list=mongo_client[:"#{key}"].find.to_a
    puts list
    if api == "get-regions"
      list.each do |l|
        l.delete("_id")
      end
      arr_elements=list
    elsif api == "get-age" || api == "get-languages"
      if api == "get-age"
        k="age"
      else
        k="language"
      end
      arr_elements=Array.new
      list.each do |a|
        ans=a["#{k}"]
        if ( arr_elements.include? ans ) == false
          arr_elements.insert(-1,ans)
        end
      end
    else
      arr_elements=Array.new
      list.each do |l|
         element=l["#{key}"]
         arr_elements.insert(-1, element)
       end
       @data=@data[0]
       puts @data
     end 
     puts arr_elements
     puts @data
     if (arr_elements - @data).empty?
       @flag=0
     else
       @flag=1
     end

     puts @flag
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
  elsif arg2 == "region"
    puts "Checking for region"
    @data.each do |data|
      if data["region"].include? 'Test Region'
        flag=1
        break
      end
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
  end
    
  Test::Unit::Assertions.assert_equal result.n, 1
end


When(/^I "([^"]*)" billing info with "([^"]*)"$/) do |operation, type|
  if operation == "update" || operation == "delete"
    @_id=@ans["data"]
  end
  
  @name=Faker::Name.name
	p=[('0'..'9')].map { |i| i.to_a }.flatten
	@phone=(0...10).map { p[rand(p.length)] }.join
  @email="chaynika+01@amagi.com"
  @address=Faker::Address.street_address
  @city=Faker::Address.city
  @state=Faker::Address.state
  @country=Faker::Address.country
  user_token=@valid_user_token
  #if type == "correct info"
    #if operation == "create"

  _id=@_id
  
  if type == "correct _id"
    _id=@_id
  elsif type == "incorrect _id"
    _id=Faker::Lorem.characters(24)
    #elsif type == "incomplete info"
  elsif type == "invalid city"
    @city=Faker::Address.city
  elsif type == "invalid phone"
		p=[('0'..'9'),('a'..'z')].map { |i| i.to_a }.flatten
		@phone=(0...10).map { p[rand(p.length)] }.join
  elsif type == "invalid email"
    @email=Faker::Lorem.word
  elsif type == "invalid user token"
    user_token=Faker::Lorem.characters(316)
  end
  if operation == "create" || operation == "create another"
    if type == "incomplete info"
      puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
          \"name\":\"#{@name}\",
          \"mobile\":\"#{@phone}\"
          }' \"http://#{$server_host}:#{$port_number}/save-billing-information\""
      output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
          "name" : "#{@name}",
          "mobile" : "#{@phone}"
          }' "http://#{$server_host}:#{$port_number}/save-billing-information"`
    else
      puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
            \"name\":\"#{@name}\",
            \"mobile\":\"#{@phone}\",
            \"email\":\"#{@email}\",
            \"address\":\"#{@address}\",
            \"city\":\"#{@city}\",
            \"state\":\"#{@state}\",
            \"country\":\"#{@country}\"
            }' \"http://#{$server_host}:#{$port_number}/save-billing-information\""
      output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
          "name" : "#{@name}",
          "mobile" : "#{@phone}",
          "email" : "#{@email}",
          "address" : "#{@address}",
          "city" : "#{@city}",
          "state" : "#{@state}",
          "country" : "#{@country}"
          }' "http://#{$server_host}:#{$port_number}/save-billing-information"`
    end
  elsif operation == "delete"
    puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
        \"_id\":\"#{_id}\"
        }' \"http://#{$server_host}:#{$port_number}/delete-billing-information\""
    output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
          "_id" : "#{_id}"
          }' "http://#{$server_host}:#{$port_number}/delete-billing-information"`
  elsif operation == "update"
    puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
        \"_id\":\"#{_id}\",
        \"mobile\":\"#{@phone}\",
        \"email\":\"#{@email}\",
        \"address\":\"#{@address}\",
        \"city\":\"#{@city}\",
        \"state\":\"#{@state}\",
        \"country\":\"#{@country}\"
        }' \"http://#{$server_host}:#{$port_number}/update-billing-information\""
    output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
        "_id" : "#{_id}",
        "mobile" : "#{@phone}",
        "email" : "#{@email}",
        "address" : "#{@address}",
        "city" : "#{@city}",
        "state" : "#{@state}",
        "country" : "#{@country}"
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

    @campaign_name="Automated_test_campaign"
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
      @campaign_budget=Faker::Number.decimal(6,2)
    else
      @campaign_budget=Faker::Number.number(6)
    end
    if action == "create with invalid start date"
      @campaign_start_date=(Date.today-10).strftime("%m/%d/%Y")
    else
      @campaign_start_date=(Date.today+10).strftime("%m/%d/%Y")
    end
    if action == "create with small duration"
      @duration=Faker::Number.between(0,6)
    elsif action == "create with large duration"
      @duration=Faker::Number.between(100,200)
    else
      @duration=Faker::Number.between(7,99)
    end

    if action == "create with invalid gender"
      @gender=Faker::Lorem.word
    else
      @gender="Male"
    end

    if action == "create with invalid age"
      @age=Faker::Lorem.word
    else
      @age="15-35"
    end
    if action == "create with invalid audience type"
      @audience_type=Faker::Lorem.word
    else
      @audience_type="Urban"
    end
    @geography="DL"
    @creative_format="Video"
    if action == "update"
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
        \"campaign_budget\": #{@campaign_budget},
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
                "campaign_budget": #{@campaign_budget},
                "campaign_start_date": "#{@campaign_start_date}",
                "duration": #{@duration}
              }
              }' "http://#{$server_host}:#{$port_number}/save-campaign"`
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
        \"campaign_budget\": #{@campaign_budget},
        \"campaign_start_date\": \"#{@campaign_start_date}\",
        \"duration\": #{@duration}
      }
      }' \"http://#{$server_host}:#{$port_number}/save-campaign\""


      output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{"campaign_settings": {"campaign_name": "#{@campaign_name}","brand_name": "#{@brand_name}","product_category": "#{@product_category}","product_sub_category": "#{@product_sub_category}","campaign_objective": "#{@campaign_objective}","gender": ["#{@gender}"],"age": ["#{@age}"],"audience_type": ["#{@audience_type}"],"geography": ["#{@geography}"],"creative_format": ["#{@creative_format}"],"currency": "#{@currency}","campaign_budget": #{@campaign_budget},"campaign_start_date": "#{@campaign_start_date}","duration": #{@duration}}}' "http://#{$server_host}:#{$port_number}/save-campaign"`
    end
    puts "Printing response from API:"
    puts output
    @ans=JSON.parse(output)

    if @ans["status"].to_i == 0
      @campaign_id=@ans["data"]["campaign_id"]
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




