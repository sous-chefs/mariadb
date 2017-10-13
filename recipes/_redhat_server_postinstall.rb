#
# Cookbook Name:: mariadb
# Recipe:: _redhat_server_postinstall
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

execute 'change first install root password' do
  command '/usr/bin/mysqladmin -u root password \'' + \
          node['mariadb']['server_root_password'] + '\''
  sensitive true
  not_if { node['mariadb']['server_root_password'].empty? }
  not_if { File.exist?('/etc/mariadb_grants') }
end
