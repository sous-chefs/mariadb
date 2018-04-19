# platform dependent attributes
case node['platform']
when 'redhat', 'centos', 'scientific', 'amazon'
  default['mariadb']['configuration']['path'] = '/etc'
  default['mariadb']['configuration']['includedir'] = '/etc/my.cnf.d'
  default['mariadb']['mysqld']['socket'] = '/var/lib/mysql/mysql.sock'
  default['mariadb']['client']['socket'] = '/var/lib/mysql/mysql.sock'
  default['mariadb']['mysqld_safe']['socket'] = '/var/lib/mysql/mysql.sock'
else
  default['mariadb']['configuration']['path'] = '/etc/mysql'
  default['mariadb']['configuration']['includedir'] = '/etc/mysql/conf.d'
  default['mariadb']['mysqld']['socket'] = '/var/run/mysqld/mysqld.sock'
  default['mariadb']['mysqld']['pid_file'] = '/var/run/mysqld/mysqld.pid'
  default['mariadb']['client']['socket'] = '/var/run/mysqld/mysqld.sock'
  default['mariadb']['mysqld_safe']['socket'] = '/var/run/mysqld/mysqld.sock'
end

default['mariadb']['sections'] = %w(mysql mysqldump mysqlcheck mysqladmin mysqlshow)

#
# mysqld default configuration
#
default['mariadb']['remove_anonymous_users']            = true
default['mariadb']['remove_test_database']              = true
default['mariadb']['forbid_remote_root']                = true
default['mariadb']['server_root_password']              = ''
default['mariadb']['root_my_cnf']                       = false
default['mariadb']['allow_root_pass_change']            = false
default['mariadb']['mysqld']['service_name'] = if node['platform'] == 'centos'
                                                 'mariadb'
                                               else
                                                 'mysql'
                                               end
default['mariadb']['mysqld']['user']                    = 'mysql'
default['mariadb']['mysqld']['port']                    = '3306'
default['mariadb']['mysqld']['basedir']                 = '/usr'
default['mariadb']['mysqld']['default_datadir']         = '/var/lib/mysql'
# if different from previous value, datadir will be moved after install
# you will have to take care about apparmor/SELinux
default['mariadb']['mysqld']['datadir']                 = '/var/lib/mysql'
default['mariadb']['mysqld']['tmpdir']                  = '/var/tmp'
default['mariadb']['mysqld']['lc_messages_dir']         = '/usr/share/mysql'
default['mariadb']['mysqld']['lc_messages']             = 'en_US'
default['mariadb']['mysqld']['skip_external_locking']   = 'true'
default['mariadb']['mysqld']['skip_log_bin']            = 'false'
default['mariadb']['mysqld']['skip_name_resolve']       = 'false'
default['mariadb']['mysqld']['bind_address']            = '127.0.0.1'
default['mariadb']['mysqld']['max_connections']         = '100'
default['mariadb']['mysqld']['max_statement_time']      = ''
default['mariadb']['mysqld']['connect_timeout']         = '5'
default['mariadb']['mysqld']['wait_timeout']            = '600'
default['mariadb']['mysqld']['max_allowed_packet']      = '16M'
default['mariadb']['mysqld']['thread_cache_size']       = '128'
default['mariadb']['mysqld']['sort_buffer_size']        = '4M'
default['mariadb']['mysqld']['bulk_insert_buffer_size'] = '16M'
default['mariadb']['mysqld']['tmp_table_size'] = '32M'
default['mariadb']['mysqld']['max_heap_table_size'] = '32M'
default['mariadb']['mysqld']['myisam_recover'] = 'BACKUP'
default['mariadb']['mysqld']['key_buffer_size'] = '128M'
# if not defined default is 2000
default['mariadb']['mysqld']['open_files_limit'] = ''
default['mariadb']['mysqld']['table_open_cache'] = '400'
default['mariadb']['mysqld']['myisam_sort_buffer_size'] = '512M'
default['mariadb']['mysqld']['concurrent_insert'] = '2'
default['mariadb']['mysqld']['read_buffer_size'] = '2M'
default['mariadb']['mysqld']['read_rnd_buffer_size'] = '1M'
default['mariadb']['mysqld']['query_cache_limit'] = '128K'
default['mariadb']['mysqld']['query_cache_size'] = '64M'
# if not defined default is ON
default['mariadb']['mysqld']['query_cache_type'] = ''
default['mariadb']['mysqld']['default_storage_engine'] = 'InnoDB'
default['mariadb']['mysqld']['options'] = {}
# logging
default['mariadb']['mysqld']['general_log_file'] = '/var/log/mysql/mysql.log'
default['mariadb']['mysqld']['general_log'] = 0
default['mariadb']['mysqld']['log_warnings'] = 2
default['mariadb']['mysqld']['slow_query_log'] = 0
default['mariadb']['mysqld']['slow_query_log_file'] = '/var/log/mysql/mariadb-slow.log'
default['mariadb']['mysqld']['long_query_time'] = 10
default['mariadb']['mysqld']['log_slow_rate_limit'] = 1000
default['mariadb']['mysqld']['log_slow_verbosity'] = 'query_plan'
default['mariadb']['mysqld']['log_output'] = 'FILE'
#
# InnoDB default configuration
#
# if not defined default is 50M
default['mariadb']['innodb']['log_file_size'] = ''
default['mariadb']['innodb']['bps_percentage_memory'] = false
default['mariadb']['innodb']['buffer_pool_size'] = '256M'
default['mariadb']['innodb']['log_buffer_size'] = '8M'
default['mariadb']['innodb']['file_per_table'] = '1'
default['mariadb']['innodb']['open_files'] = '400'
default['mariadb']['innodb']['io_capacity'] = '400'
default['mariadb']['innodb']['flush_method'] = 'O_DIRECT'
default['mariadb']['innodb']['options'] = {}

#
# Galera default configuration
#
default['mariadb']['galera']['cluster_name'] = 'galera_cluster'
default['mariadb']['galera']['cluster_search_query'] = ''
# All Galera nodes should get the same server_id
default['mariadb']['galera']['server_id']          = '100'
default['mariadb']['galera']['wsrep_sst_method']   = 'rsync'
default['mariadb']['galera']['wsrep_sst_auth']     = 'sstuser:some_secret_password'
default['mariadb']['galera']['wsrep_provider']     = \
  '/usr/lib/galera/libgalera_smm.so'
default['mariadb']['galera']['wsrep_slave_threads'] = '%{auto}'
# Default value is '1' but can be relaxed to '2' or even '0' with Galera
default['mariadb']['galera']['innodb_flush_log_at_trx_commit'] = '2'
default['mariadb']['galera']['wsrep_node_address_interface'] = ''
default['mariadb']['galera']['wsrep_node_port'] = ''
default['mariadb']['galera']['wsrep_node_incoming_address_interface'] = ''
default['mariadb']['galera']['wsrep_provider_options'] = {
  'gcache.size' => '512M'
}
default['mariadb']['galera']['options'] = {}

# Node format: [{ :name => "mariadb_1", fqdn: "33.33.33.11"}]
default['mariadb']['galera']['cluster_nodes'] = []

#
# Replication default configuration
#
default['mariadb']['replication']['server_id'] = ''
default['mariadb']['replication']['log_bin'] = \
  '/var/log/mysql/mariadb-bin'
default['mariadb']['replication']['log_bin_index'] = \
  '/var/log/mysql/mariadb-bin.index'
# Setting sync_binlog to 1 will cause a performance impact
default['mariadb']['replication']['sync_binlog']      = '0'
default['mariadb']['replication']['expire_logs_days'] = '10'
default['mariadb']['replication']['max_binlog_size'] = '100M'
default['mariadb']['replication']['options'] = {}

#
# mysqldump default configuration
#
default['mariadb']['mysqldump']['quick'] = 'true'
default['mariadb']['mysqldump']['quote_names'] = 'true'
default['mariadb']['mysqldump']['max_allowed_packet'] = '16M'

#
# isamchk default configuration
default['mariadb']['isamchk']['key_buffer'] = '16M'

#
# mysqld_safe default configuration
#
default['mariadb']['mysqld_safe']['options'] = {}

#
# client default configuration
#
default['mariadb']['client']['port'] = 3306
default['mariadb']['client']['options'] = {}
default['mariadb']['client']['development_files'] = true

#
# debian specific configuration
#
default['mariadb']['debian']['user'] = 'debian-sys-maint'
default['mariadb']['debian']['password'] = 'please-change-me'
default['mariadb']['debian']['host'] = 'localhost'

#
# mariadb default install configuration
#
# install valid value is 'package',
# hope to have 'from_source' in the near future
default['mariadb']['install']['type'] = 'package'
default['mariadb']['install']['version'] = '10.0'
default['mariadb']['install']['prefer_os_package'] = false
default['mariadb']['install']['prefer_scl_package'] = false
default['mariadb']['install']['extra_packages'] = true

#
# package(apt or yum) default configuration
#
default['mariadb']['use_default_repository'] = false
default['mariadb']['apt_repository']['base_url'] = \
  'ftp.igh.cnrs.fr/pub/mariadb/repo'

#
# MariaDB Plugins enabling
#
default['mariadb']['plugins_options']['auto_install'] = true
# Enabling Plugin Installation
default['mariadb']['plugins']['audit'] = false
# Load Plugins in .cnf (plugin-loadi variable)
default['mariadb']['plugins_loading']['audit'] = 'server_audit=server_audit.so'

# Default Configuration
default['mariadb']['audit_plugin']['server_audit_events'] = ''
default['mariadb']['audit_plugin']['server_audit_output_type'] = 'file'
# Syslog(require server_audit_output_type = syslog)
default['mariadb']['audit_plugin']['server_audit_syslog_facility'] = 'LOG_USER'
default['mariadb']['audit_plugin']['server_audit_syslog_priority'] = 'LOG_INFO'
default['mariadb']['audit_plugin']['server_audit_logging'] = 'OFF'

# Workaround to be able to use mysql2 gem compiled only on chef embedded library
default['mariadb']['mysql2_gem']['mariadb_connector_version'] = '3.0.4'
default['mariadb']['mysql2_gem']['mariadb_connector_source_url'] = 'https://github.com/MariaDB/mariadb-connector-c/archive/v3.0.4.tar.gz'
default['mariadb']['mysql2_gem']['curl_version'] = '7.59.0'
default['mariadb']['mysql2_gem']['curl_source_url'] = 'https://github.com/curl/curl/releases/download/curl-7_59_0/curl-7.59.0.tar.gz'
