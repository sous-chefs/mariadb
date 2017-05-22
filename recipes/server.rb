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

case node['mariadb']['install']['type']
when 'package'
  # Determine service name and register the resource
  service_name = mariadb_service_name(node['platform'],
                                      node['platform_version'],
                                      node['mariadb']['install']['version'],
                                      node['mariadb']['install']['prefer_os_package'],
                                      node['mariadb']['install']['prefer_scl_package'])
  node.default['mariadb']['mysqld']['service_name'] = service_name unless service_name.nil?
  service 'mysql' do
    service_name node['mariadb']['mysqld']['service_name']
    supports restart: true
    action :nothing
  end

  # Include recipe to install required repositories
  include_recipe "#{cookbook_name}::_mariadb_repository"

  # Include platform specific recipes
  case node['platform']
  when 'debian', 'ubuntu'
    include_recipe "#{cookbook_name}::_debian_server"
  when 'redhat', 'centos', 'scientific', 'amazon'
    include_recipe "#{cookbook_name}::_redhat_server"
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
    notifies :enable, 'service[mysql]'
  end
end

include_recipe "#{cookbook_name}::config"

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
    code "/usr/sbin/restorecon -v #{node['mariadb']['mysqld']['default_datadir']}"
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
    notifies :start, 'service[mysql]', :immediately
    only_if { !File.symlink?(node['mariadb']['mysqld']['default_datadir']) }
  end
end

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
  notifies :restart, 'service[mysql]', :immediately
end

if node['mariadb']['allow_root_pass_change']
  # Used to change root password after first install
  # Still experimental
  md5 = if node['mariadb']['server_root_password'].empty?
          Digest::MD5.hexdigest('empty')
        else
          Digest::MD5.hexdigest(node['mariadb']['server_root_password'])
        end

  file '/etc/mysql_root_change' do
    content md5
    action :create
    notifies :run, 'execute[install-grants]', :immediately
  end
end

if  node['mariadb']['allow_root_pass_change'] ||
    node['mariadb']['remove_anonymous_users'] ||
    node['mariadb']['forbid_remote_root'] ||
    node['mariadb']['remove_test_database']
  execute 'install-grants' do
    command '/bin/bash -e /etc/mariadb_grants \'' + \
      node['mariadb']['server_root_password'] + '\''
    only_if { File.exist?('/etc/mariadb_grants') }
    sensitive true
    action :nothing
  end
  template '/etc/mariadb_grants' do
    sensitive true
    source 'mariadb_grants.erb'
    owner 'root'
    group 'root'
    mode '0600'
    helpers MariaDB::Helper
    notifies :run, 'execute[install-grants]', :immediately
  end
end

# MariaDB Plugins
include_recipe "#{cookbook_name}::plugins" if \
  node['mariadb']['plugins_options']['auto_install']
