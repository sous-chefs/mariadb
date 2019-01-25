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
    notifies :stop, "service[#{platform_service_name}]", :immediately
    notifies :run, 'execute[apply-mariadb-root-password]', :immediately
    notifies :start, "service[#{platform_service_name}]", :delayed
  end

  # here we want to generate a new password if: 1- the user passed 'generate' to the password argument
  #                                             2- the user did not pass anything to the password argument OR
  #                                                the user did not define node['mariadb']['server_root_password'] attribute
  mariadb_root_password = (new_resource.password == 'generate' || (new_resource.password.nil? && node['mariadb']['server_root_password'].nil?)) ? secure_random : new_resource.password

  # Generate a random password or set a password defined with node['mariadb']['server_root_password'].
  # The password is set or change at each run. It is good for security if you choose to set a random password and
  # allow you to change the root password if needed.
  file 'generate-mariadb-root-password' do
    path "#{data_dir}/recovery.conf"
    owner 'mysql'
    group 'root'
    mode '640'
    sensitive true
    content "ALTER USER 'root'@'localhost' IDENTIFIED BY '#{mariadb_root_password}';"
    not_if { ::File.exist? "#{data_dir}/recovery.conf" }
  end

  pid_file = default_pid_file.nil? ? '/var/run/mysql/mysqld.pid' : default_pid_file

  # make sure that mysqld is not running, and then set the root password
  execute 'apply-mariadb-root-password' do
    user 'root'
    command "kill `cat #{pid_file}`; /usr/sbin/mysqld --init-file=#{data_dir}/recovery.conf&>/dev/null&"
    only_if { ::File.exist? "#{data_dir}/recovery.conf" }
    notifies :create, 'file[generate-mariadb-root-password]', :before
    notifies :run, 'execute[verify-root-password-okay]', :immediately
  end

  # make sure the password was properly set
  execute 'verify-root-password-okay' do
    user 'root'
    command "mysql -p#{mariadb_root_password} -e '\s'&>/dev/null && kill `cat #{pid_file}`"
  end
end

action_class do
  include MariaDBCookbook::Helpers
end
