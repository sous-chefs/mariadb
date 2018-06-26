# frozen_string_literal: true
#
# Cookbook:: mariadb
# Resource:: client_install
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

property :version,    String, default: '10.3'
property :setup_repo, [true, false], default: true

action :install do
  mariadb_repository 'Add mariadb.org repository' do
    version new_resource.version
    only_if { new_resource.setup_repo }
  end

  case node['platform_family']
  when 'debian'
    package "mariadb-client-#{new_resource.version}"
  when 'rhel', 'fedora', 'amazon'
    package 'MariaDB-client'
  end
end
