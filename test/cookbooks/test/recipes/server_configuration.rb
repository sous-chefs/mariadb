include_recipe 'test::server_install'

mariadb_server_configuration 'MariaDB Server Configuration' do
  version node['mariadb_server_test_version']
end
