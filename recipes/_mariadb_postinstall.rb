#
# Cookbook Name:: mariadb
# Recipe:: _server_postinstall
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
