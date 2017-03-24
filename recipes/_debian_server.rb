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

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  exist_data_bag_mariadb_root = begin
    search(:mariadb, 'id:user_root').first
  rescue Net::HTTPServerException, Chef::Exceptions::InvalidDataBagPath
    nil
  end

  unless exist_data_bag_mariadb_root.nil?
    data_bag_mariadb_root = data_bag_item('mariadb', 'user_root')
    node.override['mariadb']['server_root_password'] = data_bag_mariadb_root['password']
  end

  exist_data_bag_mariadb_debian = begin
    search(:mariadb, 'id:user_debian').first
  rescue Net::HTTPServerException, Chef::Exceptions::InvalidDataBagPath
    nil
  end

  unless exist_data_bag_mariadb_debian.nil?
    data_bag_mariadb_debian = data_bag_item('mariadb', 'user_debian')
    node.override['mariadb']['debian']['password'] = data_bag_mariadb_debian['password']
  end
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
  variables(package_name: 'mariadb-server')
  notifies :run, 'execute[preseed mariadb-server]', :immediately
  sensitive true
end

execute 'preseed mariadb-server' do
  command '/usr/bin/debconf-set-selections ' \
          '/var/cache/local/preseeding/mariadb-server.seed'
  action :nothing
end
