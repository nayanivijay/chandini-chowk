sql_dump_dir="/usr/amagi/dsp_dumps"

After do |tag|
  puts tag
  puts "CLEANUP is IMPORTANT!!"
  puts "Cleaning up the mess you did"
  puts "Retrieving old user table.."
  system("mysql -u #{$mysql_user} -p#{$mysql_password} -h #{$mysql_server} dsp < #{sql_dump_dir}/user.sql")
  system("export LC_ALL=\"en_US.UTF-8\"; mongorestore -h #{$mongo_server}:#{$mongo_port_no} --drop #{sql_dump_dir}/dsp/")
end
