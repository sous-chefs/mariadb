include_recipe 'test::server_install'

mariadb_server_configuration 'MariaDB Server Configuration' do
  version '10.3'
  client_port 3307
  mysqld_port 3307
end
