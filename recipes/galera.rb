#
# Cookbook Name:: mariadb
# Recipe:: galera
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
Chef::Recipe.send(:include, MariaDB::Helper)

rootpass = db_user_password(
  node['mariadb']['data_bag']['name'],
  node['mariadb']['root_user'],
  node['mariadb']['data_bag']['secret_file'],
  node['mariadb']['server_root_password'])

debianpass = db_user_password(
  node['mariadb']['data_bag']['name'],
  node['mariadb']['debian']['user'],
  node['mariadb']['data_bag']['secret_file'],
  node['mariadb']['debian']['password'])

sstuserpass = db_user_password(
  node['mariadb']['data_bag']['name'],
  node['mariadb']['galera']['wsrep_sst_user'],
  node['mariadb']['data_bag']['secret_file'],
  node['mariadb']['galera']['wsrep_sst_password'])


p "------------------TEST--------------"
p rootpass
p debianpass
p sstuserpass
p node['mariadb']['data_bag']['name']
p node['mariadb']['debian']['user']
p node['mariadb']['data_bag']['secret_file']
p node['mariadb']['debian']['password']

case node['mariadb']['install']['type']
when 'package'
  # include MariaDB repositories
  include_recipe "#{cookbook_name}::repository"

  case node['platform']
  when 'debian', 'ubuntu'
    include_recipe "#{cookbook_name}::_debian_galera"
  when 'redhat', 'centos', 'fedora', 'scientific', 'amazon'
    include_recipe "#{cookbook_name}::_redhat_galera"
  end
when 'from_source'
  # To be filled as soon as possible
end

if node['mariadb']['galera']['wsrep_sst_method'] == 'rsync'
  package 'rsync' do
    action :install
  end
else
  if node['mariadb']['galera']['wsrep_sst_method'] =~ /^xtrabackup(-v2)?/
    %w(percona-xtrabackup socat pv).each do |pkg|
      package pkg do
        action :install
      end
    end
  end
end

include_recipe "#{cookbook_name}::config"

galera_cluster_nodes = []
if !node['mariadb'].attribute?('rspec') && Chef::Config[:solo] || Chef::Config[:local_mode]
  if node['mariadb']['galera']['cluster_nodes'].empty?
    Chef::Log.warn('By default this recipe uses search (unsupported by Chef Solo).' \
                   ' Nodes may manually be configured as attributes.')
  else
    galera_cluster_nodes = node['mariadb']['galera']['cluster_nodes']
  end
else
  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  else
    if node['mariadb']['galera']['cluster_search_query'].empty?
      galera_cluster_nodes = search(
        :node, \
        "mariadb_galera_cluster_name:#{node['mariadb']['galera']['cluster_name']}"
      )
    else
      galera_cluster_nodes = search 'node', node['mariadb']['galera']['cluster_search_query']
      log 'Chef search results' do
        message "Searching for \"#{node['mariadb']['galera']['cluster_search_query']}\" \
          resulted in \"#{galera_cluster_nodes}\" ..."
      end
    end
  end
  # Sort Nodes by fqdn
  galera_cluster_nodes.sort! { |x, y| x[:fqdn] <=> y[:fqdn] }
end

first = true
gcomm = 'gcomm://'
galera_cluster_nodes.each do |lnode|
  next unless lnode.name != node.name
  gcomm += ',' unless first
  gcomm += lnode['fqdn']
  first = false
end

galera_options = {}

# Mandatory settings
galera_options['query_cache_size'] = '0'
galera_options['binlog_format'] = 'ROW'
galera_options['default_storage_engine'] = 'InnoDB'
galera_options['innodb_autoinc_lock_mode'] = '2'
galera_options['innodb_doublewrite'] = '1'
galera_options['server_id'] = \
  node['mariadb']['galera']['server_id']
# Tuning paramaters
galera_options['innodb_flush_log_at_trx_commit'] = \
  node['mariadb']['galera']['innodb_flush_log_at_trx_commit']
#
if node['mariadb']['install']['version'].to_f >= 10.1
  galera_options['wsrep_on'] = 'ON'
end
unless node['mariadb']['galera']['wsrep_provider_options'].empty?
  first = true
  wsrep_prov_opt = '"'
  node['mariadb']['galera']['wsrep_provider_options'].each do |opt, val|
    wsrep_prov_opt += ';' unless first
    wsrep_prov_opt += opt + '=' + val
    first = false
  end
  wsrep_prov_opt += '"'
  galera_options['wsrep_provider_options'] = wsrep_prov_opt
end
galera_options['wsrep_cluster_address'] = gcomm
galera_options['wsrep_cluster_name'] = \
  node['mariadb']['galera']['cluster_name']
galera_options['wsrep_sst_method'] = \
  node['mariadb']['galera']['wsrep_sst_method']
if node['mariadb']['galera'].attribute?('wsrep_sst_user') && sstuserpass
  galera_options['wsrep_sst_auth'] = \
    node['mariadb']['galera']['wsrep_sst_user'] + ':' + sstuserpass
end
galera_options['wsrep_provider'] = \
  node['mariadb']['galera']['wsrep_provider']
if node['mariadb']['galera'].attribute?('wsrep_slave_threads')
  galera_options['wsrep_slave_threads'] = \
    node['mariadb']['galera']['wsrep_slave_threads']
else
  galera_options['wsrep_slave_threads'] = node['cpu']['total'] * 4
end
unless node['mariadb']['galera']['wsrep_node_address_interface'].empty?
  ipaddress = ''
  iface = node['mariadb']['galera']['wsrep_node_address_interface']
  node['network']['interfaces'][iface]['addresses'].each do |ip, params|
    params['family'] == ('inet') && ipaddress = ip
  end
  galera_options['wsrep_node_address'] = ipaddress unless ipaddress.empty?
end
unless node['mariadb']['galera']['wsrep_node_incoming_address_interface'].empty?
  ipaddress_inc = ''
  iface = node['mariadb']['galera']['wsrep_node_incoming_address_interface']
  node['network']['interfaces'][iface]['addresses'].each do |ip, params|
    params['family'] == ('inet') && ipaddress_inc = ip
  end
  galera_options['wsrep_node_incoming_address'] = \
    ipaddress_inc unless ipaddress_inc.empty?
end
node['mariadb']['galera']['options'].each do |key, value|
  galera_options[key] = value
end

mariadb_configuration '90-galera' do
  section 'mysqld'
  option galera_options
  action :add
  sensitive true
end

#
# Under debian system we have to change the debian-sys-maint default password.
# This password is the same for the overall cluster.
#
if platform?('debian', 'ubuntu')
  template '/etc/mysql/debian.cnf' do
    sensitive true
    source 'debian.cnf.erb'
    owner 'root'
    group 'root'
    mode '0600'
    variables(
      debianpass: debianpass
    )
  end

  grants_command = 'mysql -r -B -N -u root '

  if rootpass.is_a?(String)
    grants_command += '--password=\'' + \
                      rootpass + '\' '
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
                    debianpass + '\' WITH GRANT ' \
                    'OPTION"'

  execute 'correct-debian-grants' do
    command grants_command
    action :run
    only_if do
      cmd = Mixlib::ShellOut.new("/usr/bin/mysql --user=\"" + \
        node['mariadb']['debian']['user'] + \
        "\" --password=\"" + debianpass + \
        "\" -r -B -N -e \"SELECT 1\"")
      cmd.run_command
      cmd.error?
    end
    ignore_failure true
    sensitive true
  end
end

#
# Galera SST method xtrabackup will need a seperated mysql sstuser as root
# should not be used.
#
if node['mariadb']['galera']['wsrep_sst_method'] =~ /^xtrabackup(-v2)?/

  sstuser = node['mariadb']['galera']['wsrep_sst_user']

  sstuser_cmd = 'mysql -r -B -N -u root '

  if rootpass.is_a?(String)
    sstuser_cmd += '--password=\'' + \
                   rootpass + '\' '
  end

  sstuser_cmd += '-e "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ' \
                 ' ON *.* TO \'' + sstuser + \
                 '\'@\'localhost\' ' \
                 'IDENTIFIED BY \'' + sstuserpass + '\'"'

  execute 'sstuser-grants' do
    command sstuser_cmd
    action :run
    only_if do
      cmd = Mixlib::ShellOut.new("/usr/bin/mysql --user=\"" + \
        sstuser + \
        "\" --password=\"" + sstuserpass + \
        "\" -r -B -N -e \"SELECT 1\"")
      cmd.run_command
      cmd.error?
    end
    ignore_failure true
    sensitive true
  end
end

#
#  NOTE: You cannot use the following code to restart Mariadb when in Galera mode.
#        When your SST is longer than a chef run...
#        ==> chef-client try to restart the service each time it run <==
#

# restart the service if needed
# workaround idea from https://github.com/stissot
#
# Chef::Resource::Execute.send(:include, MariaDB::Helper)
# execute 'mariadb-service-restart-needed' do
#   command 'true'
#   only_if do
#     mariadb_service_restart_required?(
#       node['mariadb']['mysqld']['bind-address'],
#       node['mariadb']['mysqld']['port'],
#       node['mariadb']['mysqld']['socket']
#     )
#   end
#   notifies :restart, 'service[mysql]', :immediately
# end
