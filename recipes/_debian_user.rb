#
# Cookbook Name:: mariadb
# Recipe:: _debian_user
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

# Configure the debian-sys-maint user
template '/etc/mysql/debian.cnf' do
  sensitive true
  source 'debian.cnf.erb'
  owner 'root'
  group 'root'
  mode '0600'
end

grants_command = 'mysql -r -B -N -u root '

if node['mariadb']['server_root_password'].is_a?(String)
  grants_command += '--password=\'' + \
    node['mariadb']['server_root_password'] + '\' '
end

grants_command += '-e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ' \
  'DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, ' \
  'INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY ' \
  'TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, ' \
  'REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ' \
  'ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON ' \
  ' *.* TO \'' + node['mariadb']['debian']['user'] + \
  '\'@\'' + node['mariadb']['debian']['host'] + '\' ' \
  'IDENTIFIED BY \'' + \
  node['mariadb']['debian']['password'] + '\' WITH GRANT ' \
  'OPTION"'

execute 'correct-debian-grants' do
  command grants_command
  action :run
  only_if do
    cmd = Mixlib::ShellOut.new('/usr/bin/mysql --user="' + \
      node['mariadb']['debian']['user'] + \
      '" --password="' + node['mariadb']['debian']['password'] + \
      '" -r -B -N -e "SELECT 1"')
    cmd.run_command
    cmd.error?
  end
  ignore_failure true
  sensitive true
end
