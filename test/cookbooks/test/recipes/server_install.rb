if platform_family?('rhel')
  package 'libselinux-utils'
  selinux_state 'enforcing'
  selinux_policy_install 'install'
end

mariadb_repository 'install'

mariadb_server_install 'package' do
  action [:install, :create]
  password 'gsql'
end

# Using this to generate a service resource to control
find_resource(:service, 'mariadb') do
  extend MariaDBCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end
