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
  if type == "new" || type == "white spaces email" || type == "alpha name"
  	$first_name=Faker::Name.first_name
  	$last_name=Faker::Name.last_name
  	if type == "alpha name"
  		$last_name="O'Neil"
  	end
  	$company_name=Faker::Company.name
  	$phone="9999999999"
  	$company_type="agency"
  	$user_type="user"
  	$email=Faker::Internet.email
  	$password=Faker::Internet.password
  elsif type == "same new"
  	first_name=$first_name
  	last_name=$last_name
  	company_name=$company_name
  	phone=$phone
  	company_type=$company_type
  	user_type=$user_type
  	email=$email
  	password=$password
  elsif type == "same email"
  	first_name=Faker::Name.first_name
  	last_name=Faker::Name.last_name
  	company_name=Faker::Company.name
  	phone="9999999999"
  	company_type="sme"
  	user_type="user"
  	email=$email
  	password=Faker::Internet.password
  elsif type == "missing"
  	first_name=Faker::Name.last_name
  	last_name=Faker::Name.last_name
  	company_name=Faker::Company.name
  	phone=Faker::Number.number(10)
  	company_type=""
  	user_type="user"
  	email=Faker::Internet.email
  	password=Faker::Internet.password
  elsif type == "invalid email"
  	o=[('a'..'z'), ('A'..'Z'), ('0'..'9'), ('!'..'?')].map { |i| i.to_a }.flatten
  	d=[('a'..'z')].map { |i| i.to_a }.flatten
  	usr=(0...8).map { o[rand(o.length)] }.join
  	domain=(0...5).map { d[rand(d.length)] }.join
  	email=usr+'..aa@'+domain+'.com'
  	first_name=$first_name
  	last_name=$last_name
  	company_name=$company_name
  	phone=$phone
  	company_type=$company_type
  	user_type=$user_type
  	password=$password
  elsif type == "invalid phone" || type == "invalid company_type"
  	first_name=Faker::Name.first_name
  	last_name=Faker::Name.last_name
  	company_name=Faker::Company.name
  	user_type="user"
  	phone="9999999999"
  	email=Faker::Internet.email
  	company_type="agency"
  	if type == "invalid phone"
  		p=[('0'..'9'), ('a'..'z')].map { |i| i.to_a }.flatten
  		phone=(0...10).map { p[rand(p.length)] }.join
  	else
  		company_type=Faker::Hacker.verb
  	end
  	password=Faker::Internet.password
  elsif type.include? "empty"
  	first_name=Faker::Name.first_name
  	last_name=Faker::Name.last_name
  	company_name="sme"
  	phone="9999999999"
  	company_type="agency"
  	user_type="user"
  	email=Faker::Internet.email
  	password=Faker::Internet.password
  	if type == "empty password"
  		password=""
  	elsif type == "empty user_type"
  		user_type=""
  	end
  end

  if type == "invalid JSON"
  	email=Faker::Internet.email
  	puts "Executing:"
  	puts "Printing a wrong format of JSON"
  	puts "curl -X POST -H \"Content-Type: application/json\" -d '{
	\"email\": \"#{email}\",
	\"password\": \"#{$password}\",
	\"first_name\": \"#{$first_name}\",
	\"last_name\": \"#{$last_name}\",
	\"company_name\": \"#{$company_name}\"
	\"phone\": \"#{$phone}\",
	\"company_type\": \"#{$company_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "#{email}",
	"password": "#{$password}",
	"first_name": "#{$first_name}",
	"last_name": "#{$last_name}",
	"company_name": "#{$company_name}"
	"phone": "#{$phone}",
	"company_type": "#{$company_type}",
	"user_type": "#{user_type}"
	}' "http://#{$server_host}:#{$port_number}/create-user"`
  elsif type == "new" || type == "alpha name"
  	puts "Executing:"
  	puts "curl -X POST -H \"Content-Type: application/json\" -d '{
	\"email\": \"#{$email}\",
	\"password\": \"#{$password}\",
	\"first_name\": \"#{$first_name}\",
	\"last_name\": \"#{$last_name}\",
	\"company_name\": \"#{$company_name}\",
	\"phone\": \"#{$phone}\",
	\"company_type\": \"#{$company_type}\",
	\"user_type\": \"#{$user_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "#{$email}",
	"password": "#{$password}",
	"first_name": "#{$first_name}",
	"last_name": "#{$last_name}",
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
	\"first_name\": \"#{$first_name}\",
	\"last_name\": \"#{$last_name}\",
	\"company_name\": \"#{$company_name}\",
	\"phone\": \"#{$phone}\",
	\"company_type\": \"#{$company_type}\",
	\"user_type\": \"#{$user_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "  #{$email}",
	"password": "#{$password}",
	"first_name": "#{$first_name}",
	"last_name": "#{$last_name}",
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
	\"first_name\": \"#{first_name}\",
	\"last_name\": \"#{last_name}\",
	\"company_name\": \"#{company_name}\",
	\"phone\": \"#{phone}\",
	\"company_type\": \"#{company_type}\",
	\"user_type\": \"#{user_type}\"
	}' \"http://#{$server_host}:#{$port_number}/create-user\""
  	output=`curl -X POST -H "Content-Type: application/json" -d '{
	"email": "#{email}",
	"password": "#{password}",
	"first_name": "#{first_name}",
	"last_name": "#{last_name}",
	"company_name": "#{company_name}",
	"phone": "#{phone}",
	"company_type": "#{company_type}",
	"user_type": "#{user_type}"
	}' "http://#{$server_host}:#{$port_number}/create-user"`
  end
  puts "Printing response from create-user API"
  puts output
  @ans=JSON.parse(output)
  @valid_user_token=@ans["data"]["user_token"]
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
  	gen_info_query="select email, first_name, last_name, company_name, phone, state, city, company_type, user_type, active from user where email='#{$email}'"

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
  if info["email"] == geninfo[0] && info["first_name"] == geninfo[1] && info["last_name"] == geninfo[2] && info["company_name"] == geninfo[3] && info["phone"] == geninfo[4] && info["state"] == geninfo[5] && info["city"] == geninfo[6] && info["company_type"] == geninfo[7] && info["user_type"] && info["active"] == active
  	flag2=0
  	puts "General info matches"
  end

  Test::Unit::Assertions.assert_equal(flag,0)
  Test::Unit::Assertions.assert_equal(flag2,0)
end

Then(/^I should see "([^"]*)" message for "([^"]*)" API$/) do |expected_message, api|
  if api == "create-user"	
  	message=@ans["error"]["title"]
  	puts "Printing error title: #{message}"

  	puts "Printing error message: #{@ans["messages"]}"
  elsif api == "login" || api == "change-password" || api == "edit-user"
  	message=@ans["messages"][0]
  	puts "Printing error message: #{message}"
  end

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
		email=Faker::Internet.email
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
end

###############################
# STEPS USED FOR:
# 1. change-password API
###############################

When(/^I change password for "([^"]*)" email with "([^"]*)" password to "([^"]*)" password$/) do |email_type, pswd_type, new_pass|
  if email_type == "valid"
  	email=$email
  elsif email_type == "invalid"
  	email=Faker::Internet.email
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

  Test::Unit::Assertions.assert_equal flag, 1
end

### edit-user API

When(/^I edit user with "([^"]*)" user token$/) do |arg1|

puts "CHANGE CODE AND REMOVE CITY AND STATE AND PUT PAN NO INSTEAD!!!"
  if arg1 == "valid" || arg1 == "valid missing" || arg1 == "valid empty"
  	user_token=@valid_user_token
  elsif arg1 == "invalid"
  	user_token=Faker::Lorem.characters(316)
  end

  new_first_name=Faker::Name.first_name
  new_last_name=Faker::Name.last_name
  new_comp_name=Faker::Company.name
  new_phone=Faker::Number.number(11)
  new_comp_type="agency"
  new_state="KA"
  new_city=Faker::Address.city
  new_email=Faker::Internet.email

  if arg1 == "valid empty"
  	new_first_name=""
  	new_phone=""
  end

  puts "Executing the following:"

  if arg1 == "valid" || arg1 == "valid empty"
  	puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
  		\"first_name\": \"#{new_first_name}\",
  		\"last_name\": \"#{new_last_name}\",
  		\"company_name\": \"#{new_comp_name}\",
  		\"company_type\": \"#{new_comp_type}\",
  		\"email\": \"#{new_email}\",
  		\"state\": \"#{new_state}\",
  		\"city\": \"#{new_city}\"
  		}' \"http://#{$server_host}:#{$port_number}/edit-user\""

  	output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
  		"first_name": "#{new_first_name}",
  		"last_name": "#{new_last_name}",
  		"company_name": "#{new_comp_name}",
  		"company_type": "#{new_comp_type}",
  		"email": "#{new_email}",
  		"state": "#{new_state}",
  		"city": "#{new_city}"
  		}' "http://#{$server_host}:#{$port_number}/edit-user"`
  else
  	puts "curl -X POST -H \"Authorization: #{user_token}\" -H \"Content-Type: application/json\" -d '{
  		\"first_name\": \"#{new_first_name}\",
  		\"last_name\": \"#{new_last_name}\",
  		\"city\": \"#{new_city}\"
  		}' \"http://#{$server_host}:#{$port_number}/edit-user\""
  	output=`curl -X POST -H "Authorization: #{user_token}" -H "Content-Type: application/json" -d '{
  		"first_name": "#{new_first_name}",
  		"last_name": "#{new_last_name}",
  		"city": "#{new_city}"
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
          if arr_elements.include? ans
            puts "..."
          else
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
        if arr_elements.include? ans
          puts "Finding if there are more elements in the array"
        else
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
     end 
     if (arr_elements - @data).empty?
       @flag=0
     else
       @flag=1
     end
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
  
  Test::Unit::Assertions.assert_equal result.n, 1
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
