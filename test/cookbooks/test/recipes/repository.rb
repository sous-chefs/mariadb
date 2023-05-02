mariadb_repository 'mariadb repo' do
  version node['mariadb_server_test_version']
end

# Save the intended mariadb version to a file for easy reference in inspec
file '/tmp/mariadb_version' do
  content node['mariadb_server_test_version']
end
