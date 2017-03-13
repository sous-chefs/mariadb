#
# Cookbook Name:: mariadb
# Recipe:: _redhat_server_native
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
# This recipe is for install and configure os shipped mariadb package

Chef::Recipe.send(:include, MariaDB::Helper)

node.default['mariadb']['mysqld']['service_name'] =
  "#{scl_collection_name(node['mariadb']['install']['version'])}-mariadb"

include_recipe 'yum-scl'

package_name = scl_package_name(node['mariadb']['install']['version'], 'mariadb-server')
package package_name do
  action :install
  notifies :enable, 'service[mysql]'
end

directory '/var/log/mysql' do
  action :create
  user 'mysql'
  group 'mysql'
  mode '0755'
  notifies :start, 'service[mysql]', :immediately
  notifies :run, 'execute[change first install root password]', :immediately
end

mysqladmin_cmd = mysqlbin_cmd(node['mariadb']['install']['prefer_scl_package'],
                              node['mariadb']['install']['version'],
                              'mysqladmin')

execute 'change first install root password' do
  command "#{mysqladmin_cmd} -u root password "\
          "'#{node['mariadb']['server_root_password']}'"
  action :nothing
  sensitive true
  not_if { node['mariadb']['server_root_password'].empty? }
end
