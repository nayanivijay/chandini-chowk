require 'toml'
require 'yaml'
require 'net/ssh'
require 'net/scp'
require 'mongo'
include Mongo

yaml_file=Dir.pwd+"/test_server.yaml"
info=YAML.load_file(yaml_file)
#info=YAML.load_file('/var/chandni-chowk/chandni-chowk-tests/test_server.yaml')
$test_server=info["test_server"]
$dsp_user=info["username"]
$dsp_password=info["password"]
$mongo_port_no=info["mongo_port_no"].to_s
$dsp_mc=info["dsp_mc"]
puts "INFO for test server:: Tests will run on #{$test_server}" #for #{$test_user} and password is #{$test_password}"
#Net::SSH.start($test_server, $test_user, :password => "#{$test_password}") do |session|
Net::SSH.start($dsp_mc, $dsp_user, :password => "#{$dsp_password}") do |session|
	session.scp.download! "/var/chandni-chowk/configs/app.development.toml", "/var/tmp"
end	
  
response=TOML.load_file("/var/tmp/app.development.toml")
$server_host=response["app"]["server_host"]
$port_number=response["app"]["server_port"]
$db_name=response["app"]["mongo_db_name"]
$mongo_db_name=response["app"]["mongo_db_name"]
$mongo_server=response["app"]["mongo_conn_str"]
if $mongo_server == "localhost"
	$mongo_server=$dsp_mc
end
$mongo_connect_string="mongodb://"+$mongo_server+":"+$mongo_port_no+"/"+$mongo_db_name
puts "INFO: #{$mongo_port_no} and #{$mongo_db_name} and #{$mongo_connect_string}"
puts "DEBUG:::...Printing environment variables..."

puts "Running tests on #{$server_host}:#{$port_number} and DB configured for tests is #{$db_name}"

mysql_conn_str=response["app"]["mysql_conn_str"]
mysql_string=mysql_conn_str.split(':').map{|x|x.split '@tcp('}.flatten.map(&:strip).reject(&:empty?)
$mysql_user=mysql_string[0]
$mysql_password=mysql_string[1]
$mysql_server=mysql_string[2]

puts "DEBUG::: MYSQL database information:: Username #{$mysql_user} and password #{$mysql_password} and MYSQL server is #{$mysql_server}"
path_script=Dir.pwd+"/features/support"
puts path_script
ans= system("#{path_script}/mysql_dumps.sh", $mysql_user, $mysql_password, $mysql_server)
if ans != true
  abort("Exiting tests!!")
end
puts "DEBUG::: Checking if it can connect to MongoDB in #{$server_host} as #{$mongo_connect_string}"

mongo_client = Mongo::Client.new($mongo_connect_string)
if mongo_client.cluster.servers.any? == false
        abort("Unable to connect to Mongo DB server. Exiting tests!!")
end



