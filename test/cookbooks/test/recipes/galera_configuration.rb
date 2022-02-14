include_recipe 'test::server_configuration'

mariadb_server_configuration 'MariaDB Server Configuration' do
  version node['mariadb_server_test_version']
end

include_recipe 'yum-epel'

mariadb_galera_configuration 'MariaDB Galera Configuration' do
  version node['mariadb_server_test_version']
  wsrep_sst_method 'mariabackup'
  action [:create, :bootstrap]
end
