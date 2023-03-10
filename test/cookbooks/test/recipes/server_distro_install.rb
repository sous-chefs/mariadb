if platform_family?('rhel')
  selinux_install 'default'
  selinux_state 'enforcing'
end

mariadb_server_install 'package' do
  action [:install, :create]
  setup_repo false
  password 'gsql'
end

# Using this to generate a service resource to control
find_resource(:service, 'mariadb') do
  extend MariaDBCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end
