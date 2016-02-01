#
# Cookbook Name:: mariadb
# Recipe:: _debian_server
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


if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  rootpass = get_password('root')
  debianpass = get_password('debian')
  # exist_data_bag_mariadb_root = search(node['mariadb']['data_bag']['name'], 'id:user_root').first
  # unless exist_data_bag_mariadb_root.nil?
  #   secret_file = Chef::EncryptedDataBagItem.load_secret(node['mariadb']['data_bag']['secret_file'])
  #   rootpass = Chef::EncryptedDataBagItem.load(node['mariadb']['data_bag']['name'], 'user_root', secret_file)['password']
  # else
  #   rootpass = node['mariadb']['server_root_password']
  # end
  #
  # exist_data_bag_mariadb_debian = search(node['mariadb']['data_bag']['name'], 'id:user_debian').first
  # unless exist_data_bag_mariadb_debian.nil?
  #   secret_file = Chef::EncryptedDataBagItem.load_secret(node['mariadb']['data_bag']['secret_file'])
  #   debianpass = Chef::EncryptedDataBagItem.load(node['mariadb']['data_bag']['name'], 'user_debian', secret_file)['password']
  # else
  #   debianpass = node['mariadb']['debian']['password']
  # end
end

# To be sure that debconf is installed
package 'debconf-utils' do
  action :install
end

# Preseed Debian Package
# (but test for resource, as it can be declared by apt recipe)
begin
  resources(directory: '/var/cache/local/preseeding')
rescue Chef::Exceptions::ResourceNotFound
  directory '/var/cache/local/preseeding' do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end
end

template '/var/cache/local/preseeding/mariadb-server.seed' do
  source 'mariadb-server.seed.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    package_name: 'mariadb-server',
    rootpass: rootpass
  )
  notifies :run, 'execute[preseed mariadb-server]', :immediately
  sensitive true
end

execute 'preseed mariadb-server' do
  command '/usr/bin/debconf-set-selections ' \
          '/var/cache/local/preseeding/mariadb-server.seed'
  action :nothing
end

package "mariadb-server-#{node['mariadb']['install']['version']}" do
  action :install
end
