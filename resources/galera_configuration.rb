#
# Cookbook:: mariadb
# Resource:: galera_configuration
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

property :version,                               String,         default: '10.3'
property :cookbook,                              String,         default: 'mariadb'
property :extra_configuration_directory,         String,         default: lazy { ext_conf_dir }
property :cluster_name,                          String,         default: 'galera_cluster'
property :cluster_search_query,                  [String, nil]
property :gcomm_address,                         [String, nil]
property :server_id,                             Integer,        default: 100
property :wsrep_sst_method,                      String,         default: 'rsync'
property :wsrep_sst_auth,                        String,         default: 'sstuser:some_secret_password'
property :wsrep_provider,                        String,         default: '/usr/lib/galera/libgalera_smm.so'
property :wsrep_slave_threads,                   String,         default: '%{auto}'
property :innodb_flush_log_at_trx_commit,        Integer,        default: 2
property :wsrep_node_address_interface,          [String, nil]
property :wsrep_node_port,                       [Integer, nil], default: nil
property :wsrep_node_incoming_address_interface, String
property :wsrep_provider_options,                Hash,           default: { 'gcache.size': '512M' }
property :options,                               Hash,           default: {}
property :cluster_nodes,                         Array,          default: []

action :create do
  case new_resource.wsrep_sst_method
  when 'rsync'
    package 'rsync'
  when /^xtrabackup(-v2)?$/
    package %w(percona-xtrabackup socat pv)
  when 'xtrabackup-v24'
    package %w(percona-xtrabackup-24 socat pv)
  when 'mariabackup'
    package %W(socat pv #{mariadbbackup_pkg_name})
  end

  mariadb_configuration '90-galera' do
    section 'mysqld'
    cookbook new_resource.cookbook
    option build_galera_options
    action :add
    sensitive true
  end
end

action_class do
  include MariaDBCookbook::Helpers

  def build_gcomm
    if new_resource.gcomm_address.nil?
      galera_cluster_nodes = []
      if new_resource.cluster_search_query.nil?
        # Let this fallback search here, but old style will work, but it's deprecated...
        # Better use a custom search query if you do not set gcomm by hand
        galera_cluster_nodes = search(
          :node, \
          "mariadb_galera_cluster_name:#{new_resource.cluster_name}"
        )
      else
        galera_cluster_nodes = search 'node', new_resource.cluster_search_query
        log 'Chef search results' do
          message "Searching for [#{new_resource.cluster_search_query}] resulted in [#{galera_cluster_nodes}]"
          level :debug
        end
      end
      # Sort Nodes by fqdn
      galera_cluster_nodes.sort! { |x, y| x[:fqdn] <=> y[:fqdn] }

      first = true
      gcomm = 'gcomm://'
      galera_cluster_nodes.each do |lnode|
        next unless lnode.name != node.name
        gcomm << ',' unless first
        gcomm << if new_resource.wsrep_node_port.nil?
                   lnode['fqdn']
                 else
                   "#{lnode['fqdn']}:#{new_resource.wsrep_node_port}"
                 end
        first = false
      end
    else
      gcomm = new_resource.gcomm_address
    end
    gcomm
  end

  def build_wsrep_node_address
    ipaddress = ''
    iface = if !new_resource.wsrep_node_address_interface.nil?
              new_resource.wsrep_node_address_interface
            else
              node['network']['interfaces'].reject { |_k, v| v.include?('flags') && v['flags'].include?('LOOPBACK') }.keys.first
            end

    if !iface.nil? && node['network']['interfaces'][iface].key?('addresses')
      node['network']['interfaces'][iface]['addresses'].each do |ip, params|
        params['family'] == 'inet' && ipaddress = ip
      end
    end
    wsrep_node_address = unless ipaddress.empty?
                           if new_resource.wsrep_node_port.nil?
                             ipaddress
                           else
                             "#{ipaddress}:#{new_resource.wsrep_node_port}"
                           end
                         end
    wsrep_node_address
  end

  def build_galera_options
    galera_options = {}
    # Mandatory Settings
    galera_options['query_cache_size'] = '0'
    galera_options['binlog_format'] = 'ROW'
    galera_options['default_storage_engine'] = 'InnoDB'
    galera_options['innodb_autoinc_lock_mode'] = '2'
    galera_options['innodb_doublewrite'] = '1'
    galera_options['server_id'] = new_resource.server_id
    # Tuning paramaters
    galera_options['innodb_flush_log_at_trx_commit'] = new_resource.innodb_flush_log_at_trx_commit
    galera_options['wsrep_on'] = 'ON' if new_resource.version.to_f >= 10.1
    unless new_resource.wsrep_provider_options.nil?
      first = true
      wsrep_prov_opt = '"'
      new_resource.wsrep_provider_options.each do |opt, val|
        wsrep_prov_opt << ';' unless first
        wsrep_prov_opt << opt.to_s
        wsrep_prov_opt << '='
        wsrep_prov_opt << val
        first = false
      end
      wsrep_prov_opt << '"'
      galera_options['wsrep_provider_options'] = wsrep_prov_opt
    end
    galera_options['wsrep_cluster_address'] = build_gcomm
    galera_options['wsrep_cluster_name'] = new_resource.cluster_name
    galera_options['wsrep_sst_method'] = if new_resource.wsrep_sst_method == 'xtrabackup-v24'
                                           'xtrabackup'
                                         else
                                           new_resource.wsrep_sst_method
                                         end
    unless new_resource.wsrep_sst_auth.nil?
      galera_options['wsrep_sst_auth'] = new_resource.wsrep_sst_auth
    end
    galera_options['wsrep_provider'] = new_resource.wsrep_provider
    galera_options['wsrep_slave_threads'] = format(new_resource.wsrep_slave_threads.to_s, auto: node['cpu']['total'] * 4)

    galera_options['wsrep_node_address'] = build_wsrep_node_address
    ipaddress_inc = ''
    unless new_resource.wsrep_node_incoming_address_interface.nil?
      iface_enc = new_resource.wsrep_node_incoming_address_interface
      node['network']['interfaces'][iface_enc]['addresses'].each do |ip, params|
        params['family'] == 'inet' && ipaddress_inc = ip
      end
      galera_options['wsrep_node_incoming_address'] = ipaddress_inc unless ipaddress_inc.empty?
    end

    new_resource.options.each do |key, value|
      galera_options[key] = value
    end
    galera_options
  end
end
