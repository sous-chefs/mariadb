# This resource should install the mariadb client
mariadb_client_install 'mariadb client' do
  version node['mariadb_server_test_version']
end
