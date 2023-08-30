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
provides :mariadb_server_install
unified_mode true

include MariaDBCookbook::Helpers

property :version,           String,               default: '10.11'
property :setup_repo,        [true, false],        default: true
property :password,          [String, nil],        default: 'generate'
property :install_sleep,     Integer,              default: 5, desired_state: false
property :package_action,    [:install, :upgrade], default: :install

action :install do
  mariadb_client_install 'Install MariaDB Client' do
    version new_resource.version
    setup_repo new_resource.setup_repo
    package_action new_resource.package_action
  end

  package server_pkg_name do
    action new_resource.package_action
  end

  selinux_install 'mariadb' if selinux_enabled?

  # This should get automatically installed via the package, but in case it doesn't ensure it does here
  # https://mariadb.com/kb/en/selinux/
  selinux_module 'mariadb' do
    base_dir default_selinux_module_path
    only_if { selinux_enabled? && Dir.exist?(default_selinux_module_path) }
    action :install
  end

  # Ensure that the database is running.
  service 'mariadb' do
    action [:enable, :start]
  end
end

action :create do
  find_resource(:service, 'mariadb') do
    service_name lazy { platform_service_name }
    supports restart: true, status: true, reload: true
    action :nothing
  end

  # here we want to generate a new password if: 1- the user passed 'generate' to the password argument
  #                                             2- the user did not pass anything to the password argument OR
  #                                                the user did not define node['mariadb']['server_root_password'] attribute
  mariadb_root_password = (new_resource.password == 'generate' || new_resource.password.nil?) ? secure_random : new_resource.password

  # Here we make sure to escape all \ ' and " characters so that they will be preserved in the final password
  mariadb_root_password = mariadb_root_password.gsub('\\', '\\\\\\').gsub('\'', '\\\\\'').gsub('"', '\\\\"')

  # Store the password in the run state for any other resources that may need it.
  node.run_state['mariadb_root_password'] = mariadb_root_password

  # Generate a random password or set a password defined with node['mariadb']['server_root_password'].
  # The password is set or change at each run. It is good for security if you choose to set a random password and
  # allow you to change the root password if needed.

  # Generate the query to send to the database in order to update the root password
  set_password_command = mariadb_password_command(mariadb_root_password)

  file 'generate-mariadb-root-password' do
    path "#{data_dir}/recovery.conf"
    owner 'mysql'
    group 'root'
    mode '640'
    sensitive true
    content set_password_command
    action :nothing
  end

  pid_file = default_pid_file
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
    command "(test -f #{pid_file} && kill `cat #{pid_file}` && sleep #{new_resource.install_sleep}); #{default_mysqld_path} -u root --pid-file=#{pid_file} --init-file=#{data_dir}/recovery.conf&>/dev/null& sleep #{new_resource.install_sleep} && (test -f #{pid_file} && kill `cat #{pid_file}`) && sleep #{new_resource.install_sleep}"
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
  include Chef::Util::Selinux
end
