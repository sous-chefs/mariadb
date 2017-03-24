#
# Cookbook Name:: mariadb
# Recipe:: _redhat_repository
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

if use_scl_package?(node['mariadb']['install']['prefer_scl_package'],
                     node['platform'], node['platform_version']) &&
   scl_version_available?(node['mariadb']['install']['version'])
  # SCL repository
  include_recipe 'yum-scl'
elsif !use_os_native_package?(node['mariadb']['install']['prefer_os_package'],
                              node['platform'], node['platform_version'])
  # MariaDB repository
  include_recipe "#{cookbook_name}::repository"
end
