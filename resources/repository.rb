# frozen_string_literal: true
#
# Cookbook:: mariadb
# Resource:: repository
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

property :version,            String, default: '10.3'
property :enable_mariadb_org, [true, false], default: true
property :yum_gpg_key_uri,    String, default: 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
property :apt_gpg_keyserver,  String, default: 'keyserver.ubuntu.com'
property :apt_gpg_key,        String, default: lazy {
  if node['lsb']['codename'] == 'buster' || node['lsb']['codename'] == 'buster/sid'
    'F1656F24C74CD1D8'
  elsif platform?('ubuntu') && node['platform_version'].to_i < 9
    'CBCB082A1BB943DB'
  else
    'F1656F24C74CD1D8'
  end
}
property :apt_key_proxy,      [String, false], default: false
property :apt_repository_uri, String, default: 'http://mariadb.mirrors.ovh.net/MariaDB/repo'

action :add do
  case node['platform_family']

  when 'rhel', 'fedora', 'amazon'
    remote_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB-#{new_resource.version}" do
      source new_resource.yum_gpg_key_uri
    end

    # yum repository workaround for CentOS 8 and RHEL 8
    # https://jira.mariadb.org/browse/MDEV-20673
    opts = {}
    if platform_family?('rhel') && node['platform_version'].to_f >= 8
      opts[:module_hotfixes] = 1
    end

    yum_repository "MariaDB #{new_resource.version}" do
      repositoryid "mariadb#{new_resource.version}"
      description "MariaDB.org #{new_resource.version}"
      baseurl     yum_repo_url('http://yum.mariadb.org')
      enabled     new_resource.enable_mariadb_org
      options     opts
      gpgcheck    true
      gpgkey      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB-#{new_resource.version}"
    end

  when 'debian'
    apt_update
    package 'apt-transport-https'
    package 'dirmngr' if (platform?('ubuntu') && node['platform_version'].to_i >= 9) || (platform?('ubuntu') && node['platform_version'].to_i >= 18)

    apt_repository 'mariadb_org_repository' do
      uri          "#{new_resource.apt_repository_uri}/#{new_resource.version}/#{node['platform']}"
      components   ['main']
      keyserver new_resource.apt_gpg_keyserver
      key new_resource.apt_gpg_key
      key_proxy new_resource.apt_key_proxy
      cache_rebuild true
    end
  else
    raise "The platform_family '#{node['platform_family']}' or platform '#{node['platform']}' is not supported by the mariadb_repository resource. If you believe this platform can/should be supported by this resource please file and issue or open a pull request at https://github.com/sous-chefs/mariadb"
  end
end

action_class do
  include MariaDBCookbook::Helpers
end
