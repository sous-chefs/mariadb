#
# Cookbook Name:: mariadb
# Recipe:: server
#
# Copyright 2014, blablacar.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Chef::Recipe.send(:include, MariaDB::Helper)

extend Chef::Util::Selinux
selinux_enabled = selinux_enabled?

# --[ INSTALL ]------------------------

case node['mariadb']['install']['type']
when 'package'
  # Determine service name and register the resource
  service_name = mariadb_service_name(node['platform'],
                                      node['platform_version'],
                                      node['mariadb']['install']['version'],
                                      node['mariadb']['install']['prefer_os_package'],
                                      node['mariadb']['install']['prefer_scl_package'])
  node.default['mariadb']['mysqld']['service_name'] = service_name unless service_name.nil?

  # Include recipe to install required repositories
  include_recipe "#{cookbook_name}::_mariadb_repository"

  # Include platform specific recipes
  case node['platform']
  when 'debian', 'ubuntu'
    include_recipe "#{cookbook_name}::_debian_server_preinstall"
    platform_post_install_recipe = "#{cookbook_name}::_debian_server_postinstall"
  when 'redhat', 'centos', 'scientific', 'amazon'
    include_recipe "#{cookbook_name}::_redhat_server_preinstall"
    platform_post_install_recipe = "#{cookbook_name}::_redhat_server_postinstall"
  end

  # Install server package
  server_package_name = packages_names_to_install(node['platform'],
                                                  node['platform_version'],
                                                  node['mariadb']['install']['version'],
                                                  node['mariadb']['install']['prefer_os_package'],
                                                  node['mariadb']['install']['prefer_scl_package'])['server']
  package 'MariaDB-server' do
    package_name server_package_name
    action :install
    notifies :run, 'ruby_block[restart_mysql]', :immediately
  end

end

# --[ CONFIGURE ]------------------------

include_recipe "#{cookbook_name}::config"

directory '/var/log/mysql' do
  owner 'mysql'
  group 'mysql'
  mode '0755'
end

# move the datadir if needed
if node['mariadb']['mysqld']['datadir'] !=
    node['mariadb']['mysqld']['default_datadir']

  bash 'move-datadir' do
    user 'root'
    code <<-EOH
    /bin/cp -a #{node['mariadb']['mysqld']['default_datadir']}/* \
               #{node['mariadb']['mysqld']['datadir']} &&
    /bin/rm -r #{node['mariadb']['mysqld']['default_datadir']} &&
    /bin/ln -s #{node['mariadb']['mysqld']['datadir']} \
               #{node['mariadb']['mysqld']['default_datadir']}
    EOH
    action :nothing
  end

  bash 'Restore security context' do
    user 'root'
    code "/sbin/restorecon -v #{node['mariadb']['mysqld']['default_datadir']}"
    only_if { selinux_enabled }
    subscribes :run, 'bash[move-datadir]', :immediately
    action :nothing
  end

  directory node['mariadb']['mysqld']['datadir'] do
    owner 'mysql'
    group 'mysql'
    mode '0750'
    action :create
    notifies :stop, 'service[mysql]', :immediately
    notifies :run, 'bash[move-datadir]', :immediately
    notifies :run, 'ruby_block[restart_mysql]', :immediately
    only_if { !File.symlink?(node['mariadb']['mysqld']['default_datadir']) }
  end
end

# --[ START SERVICE ]------------------------

# restart the service if needed
# workaround idea from https://github.com/stissot
Chef::Resource::Execute.send(:include, MariaDB::Helper)
execute 'mariadb-service-restart-needed' do
  command 'true'
  only_if do
    mariadb_service_restart_required?(
      node['mariadb']['mysqld']['bind_address'],
      node['mariadb']['mysqld']['port'],
      node['mariadb']['mysqld']['socket']
    )
  end
  notifies :run, 'ruby_block[restart_mysql]', :immediately
end

# Service definition allowing timely restart

service 'mysql' do
  service_name node['mariadb']['mysqld']['service_name']
  supports restart: true, reload: true
  action [:start, :enable]
end

ruby_block 'restart_mysql' do
  block do
    r = resources(service: 'mysql')
    a = Array.new(r.action)

    a << :restart unless a.include?(:restart)
    a.delete(:start) if a.include?(:restart)

    r.action(a)
  end
  action :nothing
end

# --[ POST INSTALL ]------------------------

case node['mariadb']['install']['type']
when 'package'
  include_recipe platform_post_install_recipe
end

include_recipe "#{cookbook_name}::_mariadb_postinstall"

# MariaDB Plugins
include_recipe "#{cookbook_name}::plugins" if \
  node['mariadb']['plugins_options']['auto_install']
