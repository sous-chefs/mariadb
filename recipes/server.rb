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

case node['mariadb']['install']['type']
when 'package'
  include_recipe "#{cookbook_name}::repository"

  case node['platform']
  when 'debian', 'ubuntu'
    package "mariadb-server-#{node['mariadb']['install']['version']}" do
      action :install
    end
  when 'redhat', 'centos', 'fedora'
    package 'MariaDB-server' do
      action :install
    end

    directory '/var/log/mysql' do
      action :create
      user 'mysql'
      group 'mysql'
      mode '0755'
    end
  end
when 'from_source'
  # To be filled as soon as possible
end

include_recipe "#{cookbook_name}::config"

# restart the service if needed
# workaround idea from https://github.com/stissot
Chef::Resource::Service.send(:include, MariaDB::Helper)
service 'mysql' do
  action :restart
  only_if do
    mariadb_service_restart_required?(
      '127.0.0.1',
      node['mariadb']['mysqld']['port'],
      node['mariadb']['mysqld']['socket']
    )
  end
end
