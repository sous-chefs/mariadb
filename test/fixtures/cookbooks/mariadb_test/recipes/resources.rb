::Chef::Recipe.send(:include, HashedPassword::Helper)

include_recipe 'mariadb::server'

# Create a schema to test mysql_database :drop against
bash 'create datatrout' do
  code <<-EOF
  echo 'CREATE SCHEMA datatrout;' | /usr/bin/mysql -u root -pgsql;
  touch /tmp/troutmarker
  EOF
  not_if 'test -f /tmp/troutmarker'
  action :run
end

# Create a database for testing existing grant operations
bash 'create datasalmon' do
  code <<-EOF
  echo 'CREATE SCHEMA datasalmon;' | /usr/bin/mysql -u root -pgsql;
  touch /tmp/salmonmarker
  EOF
  not_if 'test -f /tmp/salmonmarker'
  action :run
end

# Create a user to test mysql_database_user :drop against
bash 'create kermit' do
  code <<-EOF
  echo "CREATE USER 'kermit'@'localhost';" | /usr/bin/mysql -u root -pgsql;
  touch /tmp/kermitmarker
  EOF
  not_if 'test -f /tmp/kermitmarker'
  action :run
end

# Create a user to test mysql_database_user password update via :create
bash 'create rowlf' do
  code <<-EOF
  echo "CREATE USER 'rowlf'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -pgsql;
  touch /tmp/rowlfmarker
  EOF
  not_if 'test -f /tmp/rowlfmarker'
  action :run
end

# Create a user to test mysql_database_user password update via :create using a password hash
bash 'create statler' do
  code <<-EOF
  echo "CREATE USER 'statler'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -pgsql;
  touch /tmp/statlermarker
  EOF
  not_if 'test -f /tmp/statlermarker'
  action :run
end

# Create a user to test mysql_database_user password update via :grant
bash 'create rizzo' do
  code <<-EOF
  echo "GRANT SELECT ON datasalmon.* TO 'rizzo'@'127.0.0.1' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -pgsql;
  touch /tmp/rizzomarker
  EOF
  not_if 'test -f /tmp/rizzomarker'
  action :run
end

## Resources we're testing
mariadb_database 'databass' do
  action :create
end

mariadb_database 'datatrout' do
  action :drop
end

mariadb_user 'piggy' do
  action :create
end

mariadb_user 'kermit' do
  action :drop
end

mariadb_user 'rowlf' do
  password '123456' # hashed: *6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9
  action :create
end

mariadb_user 'gonzo' do
  password 'abcdef'
  host '10.10.10.%'
  action :create
end

# create gonzo again to ensure the create action is idempotent
mariadb_user 'gonzo' do
  password 'abcdef'
  host '10.10.10.%'
  action :create
end

hash = hashed_password('*2027D9391E714343187E07ACB41AE8925F30737E'); # 'l33t'

mariadb_user 'statler' do
  password hash
  action :create
end

mariadb_user 'fozzie' do
  database_name 'databass'
  password 'wokkawokka'
  host 'mars'
  privileges [:select, :update, :insert]
  require_ssl true
  action :grant
end

hash2 = hashed_password('*F798E7C0681068BAE3242AA2297D2360DBBDA62B'); # 'zokkazokka'

mariadb_user 'moozie' do
  database_name 'databass'
  password hash2
  host '127.0.0.1'
  privileges [:select, :update, :insert]
  require_ssl false
  action :grant
end

# all the grants exist ('Granting privs' should not show up), but the password is different
# and should get updated
mariadb_user 'rizzo' do
  database_name 'datasalmon'
  password 'salmon'
  host '127.0.0.1'
  privileges [:select]
  require_ssl false
  action :grant
end

mariadb_database 'flush privileges' do
  database_name 'databass'
  sql 'flush privileges'
  action :query
end
