include_recipe 'test::server_configuration'

mariadb_server_configuration 'MariaDB Server Configuration' do
  version '10.3'
end

mariadb_galera_configuration 'MariaDB Galera Configuration' do
  version '10.3'
  wsrep_sst_method 'mariabackup'
end
