#
# Cookbook Name:: mariadb
# Recipe:: _redhat_server
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

use_os_native = use_os_native_package?(node['mariadb']['install']['prefer_os_package'],
                                       node['platform'],
                                       node['platform_version'])
use_scl = use_scl_package?(node['mariadb']['install']['prefer_scl_package'],
                           node['platform'],
                           node['platform_version']) &&
          scl_version_available?(node['mariadb']['install']['version'])

# To force removing of mariadb-libs on CentOS >= 7
package 'MariaDB-shared' do
  action :install
  not_if { use_os_native || use_scl }
end

ruby_block 'MariaDB first start' do
  block do
    true
  end
  action :nothing
  subscribes :run, 'package[MariaDB-server]', :immediately
  notifies :create, 'directory[/var/log/mysql]', :immediately
  notifies :start, 'service[mysql]', :immediately
  notifies :run, 'execute[change first install root password]', :immediately
end

directory '/var/log/mysql' do
  action :nothing
  user 'mysql'
  group 'mysql'
  mode '0755'
end

execute 'change first install root password' do
  command '/usr/bin/mysqladmin -u root password \'' + \
    node['mariadb']['server_root_password'] + '\''
  action :nothing
  sensitive true
  not_if { node['mariadb']['server_root_password'].empty? }
end
