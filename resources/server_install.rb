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

  # here we want to generate a new password if: 1- the user passed 'generate' to the password argument
  #                                             2- the user did not pass anything to the password argument OR
  #                                                the user did not define node['mariadb']['server_root_password'] attribute
  mariadb_root_password = (new_resource.password == 'generate' || new_resource.password.nil?) ? secure_random : new_resource.password

  # Generate a random password or set a password defined with node['mariadb']['server_root_password'].
  # The password is set or change at each run. It is good for security if you choose to set a random password and
  # allow you to change the root password if needed.
  file 'generate-mariadb-root-password' do
    path "#{data_dir}/recovery.conf"
    owner 'mysql'
    group 'root'
    mode '640'
    sensitive true
    content "use mysql;
update user set password=PASSWORD('#{mariadb_root_password}') where User='root';
flush privileges;"
    action :nothing
  end

  pid_file = default_pid_file.nil? ? '/var/run/mysqld/mysqld.pid' : default_pid_file
  pid_dir = ::File.dirname(pid_file)

  # because some distros may not take care of the pid file location directory, we manage it ourselves
  directory pid_dir do
    owner 'mysql'
    group 'mysql'
    mode '755'
    recursive true
    action :nothing
  end

  # make sure that mysqld is not running, and then set the root password and make sure the mysqld process is killed after setting the password
  execute 'apply-mariadb-root-password' do
    user 'mysql'
    # TODO, I really dislike the sleeps here, should come up with a better way to do this
    command "(test -f #{pid_file} && kill `cat #{pid_file}` && sleep 3); /usr/sbin/mysqld -u root --pid-file=#{pid_file} --init-file=#{data_dir}/recovery.conf&>/dev/null& sleep 2 && (test -f #{pid_file} && kill `cat #{pid_file}`)"
    notifies :enable, "service[#{platform_service_name}]", :before
    notifies :stop, "service[#{platform_service_name}]", :before
    notifies :create, 'file[generate-mariadb-root-password]', :before
    notifies :create, "directory[#{pid_dir}]", :before
    notifies :start, "service[#{platform_service_name}]", :immediately
    action :run
    not_if "mysql -B -uroot -p#{mariadb_root_password} -e 'SELECT 1;' > /dev/null"
  end
end

action_class do
  include MariaDBCookbook::Helpers
end
