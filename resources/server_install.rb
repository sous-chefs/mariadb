# frozen_string_literal: true
#
# Cookbook:: mariadb
# Resource:: server_install
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

include MariaDBCookbook::Helpers

property :version,           String,        default: '10.3'
property :setup_repo,        [true, false], default: true
property :mycnf_file,        String,        default: lazy { "#{conf_dir}/my.cnf" }
property :extconf_directory, String,        default: lazy { ext_conf_dir }
property :data_directory,    String,        default: lazy { data_dir }
property :external_pid_file, String,        default: lazy { "/var/run/mysql/#{version}-main.pid" }
property :password,          [String, nil], default: 'generate'
property :port,              Integer,       default: 3306
property :initdb_locale,     String,        default: 'UTF-8'

action :install do
  node.run_state['mariadb'] ||= {}
  node.run_state['mariadb']['version'] = new_resource.version

  mariadb_client_install 'Install MariaDB Client' do
    version new_resource.version
    setup_repo new_resource.setup_repo
  end

  package server_pkg_name
end

action :create do
  find_resource(:service, 'mysql') do
    service_name lazy { platform_service_name }
    supports restart: true, status: true, reload: true
    action :nothing
  end

  log 'Enable and start MariaDB service' do
    notifies :enable, "service[#{platform_service_name}]", :immediately
    notifies :start, "service[#{platform_service_name}]", :immediately
  end

  mariadb_root_password = new_resource.password == 'generate' || new_resource.password.nil? ? secure_random : new_resource.password

  # Generate a random password or set the a password defined with node['mariadb']['server_root_password'].
  # The password is set or change at each run. It is good for security if you choose to set a random password and
  # allow you to change the root password if needed.
  execute 'generate-mariadb-root-password' do
    user 'root'
    command "/usr/bin/mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '#{mariadb_root_password}';\""
    not_if { ::File.exist? "#{data_dir}/recovery.conf" }
    only_if { !new_resource.password.nil? }
  end
end

action_class do
  include MariaDBCookbook::Helpers
end
