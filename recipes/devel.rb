#
# Cookbook Name:: mariadb
# Recipe:: client
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

# rubocop:disable Lint/EmptyWhen

Chef::Recipe.send(:include, MariaDB::Helper)
case node['mariadb']['install']['type']
when 'package'
  # Include recipes to install repositories
  include_recipe "#{cookbook_name}::_mariadb_repository"

  # Install devel package
  devel_package_name = packages_names_to_install(node['platform'],
                                                 node['platform_version'],
                                                 node['mariadb']['install']['version'],
                                                 node['mariadb']['install']['prefer_os_package'],
                                                 node['mariadb']['install']['prefer_scl_package'])['devel']
  package 'MariaDB-devel' do
    package_name devel_package_name
    action :install
  end

when 'from_source'
  # To be filled as soon as possible
end
