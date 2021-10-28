include_recipe 'test::server_configuration'

mariadb_server_configuration 'MariaDB Server Configuration' do
  version node['mariadb_server_test_version']
end

yum_repository 'epel' do
  mirrorlist "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-#{node['platform_version'].to_i}&arch=$basearch"
  gpgkey "https://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{node['platform_version'].to_i}"
  only_if { platform?('centos') }
end

mariadb_galera_configuration 'MariaDB Galera Configuration' do
  version node['mariadb_server_test_version']
  wsrep_sst_method 'mariabackup'
  action [:create, :bootstrap]
end
