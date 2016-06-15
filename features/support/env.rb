require 'toml'
require 'yaml'
require 'net/ssh'
require 'net/scp'
require 'mongo'
include Mongo

info=YAML.load_file('/var/chandni-chowk/chandni-chowk-tests/test_server.yaml')
$test_server=info["test_server"]
$test_user=info["username"]
$test_password=info["password"]
$mongo_port_no=info["mongo_port_no"].to_s
puts "INFO for test server:: Tests will run on #{$test_server} for #{$test_user} and password is #{$test_password}"
#Net::SSH.start($test_server, $test_user, :password => "#{$test_password}") do |session|
#	session.scp.download! "/var/chandni-chowk/configs/app.development.toml", "/var/tmp"
#end	
  
response=TOML.load_file("/var/tmp/app.development.toml")
$server_host=response["app"]["server_host"]
$port_number=response["app"]["server_port"]
$db_name=response["app"]["mongo_db_name"]
$mongo_db_name=response["app"]["mongo_db_name"]
$mongo_connect_string="mongodb://"+$server_host+":"+$mongo_port_no+"/"+$mongo_db_name
puts "INFO: #{$mongo_port_no} and #{$mongo_db_name} and #{$mongo_connect_string}"
puts "DEBUG:::...Printing environment variables..."

puts "Running tests on #{$server_host}:#{$port_number} and DB configured for tests is #{$db_name}"

mysql_conn_str=response["app"]["mysql_conn_str"]
mysql_string=mysql_conn_str.split(':').map{|x|x.split '@'}.flatten.map(&:strip).reject(&:empty?)
$mysql_user=mysql_string[0]
$mysql_password=mysql_string[1]

puts "DEBUG::: MYSQL database information:: Username #{$mysql_user} and password #{$mysql_password}"

puts "DEBUG::: Checking if it can connect to MongoDB in #{$server_host} as #{$mongo_connect_string}"

mongo_client = Mongo::Client.new($mongo_connect_string)



