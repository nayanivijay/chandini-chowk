sql_dump_dir="/var/tmp/chandni-chowk-db-dumps"

After do |tag|
  puts tag
  puts "CLEANUP is IMPORTANT!!"
  puts "Cleaning up the mess you did"
  puts "Retrieving old user table.."
  system("mysql -u #{$mysql_user} -p#{$mysql_password} dsp < #{sql_dump_dir}/user.sql")
  puts "Retrieving old dsp table.."
  system("mysql -u #{$mysql_user} -p#{$mysql_password} dsp < #{sql_dump_dir}/dsp.sql")
end
