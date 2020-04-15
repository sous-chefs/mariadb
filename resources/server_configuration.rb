# frozen_string_literal: true
#
# Cookbook:: mariadb
# Resource:: server_configuration
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

property :version,                        String,            default: '10.3'
property :cookbook,                       String,            default: 'mariadb'
property :mycnf_file,                     String,            default: lazy { "#{conf_dir}/my.cnf" }
property :extra_configuration_directory,  String,            default: lazy { ext_conf_dir }
property :client_port,                    [String, Integer], default: 3306
property :client_socket,                  String,            default: lazy { default_socket }
property :client_host,                    [String, nil]
property :client_options,                 Hash,              default: {}
property :mysqld_safe_socket,             String,            default: lazy { default_socket }
property :mysqld_safe_nice,               [String, Integer], default: 0
property :mysqld_safe_options,            Hash,              default: {}
property :mysqld_user,                    String,            default: 'mysql'
property :mysqld_pid_file,                [String, nil],     default: lazy { default_pid_file }
property :mysqld_socket,                  String,            default: lazy { default_socket }
property :mysqld_basedir,                 String,            default: '/usr'
property :mysqld_datadir,                 String,            default: '/var/lib/mysql'
property :mysqld_tmpdir,                  String,            default: '/var/tmp'
property :mysqld_lc_messages_dir,         String,            default: '/usr/share/mysql'
property :mysqld_lc_messages,             String,            default: 'en_US'
property :mysqld_skip_external_locking,   [true, false],     default: true
property :mysqld_skip_log_bin,            [true, false],     default: false
property :mysqld_skip_name_resolve,       [true, false],     default: false
property :mysqld_bind_address,            String,            default: '127.0.0.1'
property :mysqld_port,                    [String, Integer], default: 3306
property :mysqld_max_connections,         Integer,           default: 100
property :mysqld_max_statement_time,      [Integer, nil],    default: nil
property :mysqld_connect_timeout,         Integer,           default: 5
property :mysqld_wait_timeout,            Integer,           default: 600
property :mysqld_max_allowed_packet,      String,            default: '16M'
property :mysqld_thread_cache_size,       Integer,           default: 128
property :mysqld_sort_buffer_size,        String,            default: '4M'
property :mysqld_bulk_insert_buffer_size, String,            default: '16M'
property :mysqld_tmp_table_size,          String,            default: '32M'
property :mysqld_max_heap_table_size,     String,            default: '32M'
property :mysqld_myisam_recover,          String,            default: 'BACKUP'
property :mysqld_key_buffer_size,         String,            default: '128M'
property :mysqld_open_files_limit,        [Integer, nil],    default: nil
property :mysqld_table_open_cache,        Integer,           default: 400
property :mysqld_myisam_sort_buffer_size, String,            default: '512M'
property :mysqld_concurrent_insert,       Integer,           default: 2
property :mysqld_read_buffer_size,        String,            default: '2M'
property :mysqld_read_rnd_buffer_size,    String,            default: '1M'
property :mysqld_query_cache_limit,       String,            default: '128K'
property :mysqld_query_cache_size,        String,            default: '64M'
property :mysqld_query_cache_type,        [String, nil]
property :mysqld_default_storage_engine,  String,            default: 'InnoDB'
property :mysqld_log_directory,           String,            default: '/var/log/mysql'
property :mysqld_general_log_file,        String,            default: lazy { "#{mysqld_log_directory}/mysql.log" }
property :mysqld_general_log,             Integer,           default: 0
property :mysqld_log_warnings,            Integer,           default: 2
property :mysqld_slow_query_log,          Integer,           default: 0
property :mysqld_slow_query_log_file,     String,            default: lazy { "#{mysqld_log_directory}/mariadb-slow.log" }
property :mysqld_long_query_time,         Integer,           default: 10
property :mysqld_log_slow_rate_limit,     Integer,           default: 1000
property :mysqld_log_slow_verbosity,      String,            default: 'query_plan'
property :mysqld_log_output,              String,            default: 'FILE'
property :mysqld_options,                 Hash,              default: {}
property :mysqldump_quick,                [true, false],     default: true
property :mysqldump_quote_names,          [true, false],     default: true
property :mysqldump_max_allowed_packet,   String,            default: '16M'
property :mysqldump_options,              Hash,              default: {}
property :isamchk_key_buffer,             String,            default: '16M'
property :isamchk_options,                Hash,              default: {}
property :innodb_log_file_size,           String,            default: '50M'
property :innodb_bps_percentage_memory,   [true, false],     default: false
property :innodb_buffer_pool_size,        String,            default: '50M'
property :innodb_log_buffer_size,         String,            default: '8M'
property :innodb_file_per_table,          Integer,           default: 1
property :innodb_open_files,              Integer,           default: 400
property :innodb_io_capacity,             Integer,           default: 400
property :innodb_flush_method,            String,            default: 'O_DIRECT'
property :innodb_options,                 Hash,              default: {}
property :replication_server_id,          [String, nil]
property :replication_log_bin,            [String, nil],     default: lazy { "#{mysqld_log_directory}/mariadb-bin" }
property :replication_log_bin_index,      String,            default: lazy { "#{mysqld_log_directory}/mariadb-bin.index" }
property :replication_sync_binlog,        [String, Integer], default: 0
property :replication_expire_logs_days,   Integer,           default: 10
property :replication_max_binlog_size,    String,            default: '100M'
property :replication_options,            Hash,              default: {}

action :modify do
  template new_resource.mycnf_file do
    source 'my.cnf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    cookbook new_resource.cookbook
    variables(client_port: new_resource.client_port,
              client_socket: new_resource.client_socket,
              client_host: new_resource.client_host,
              client_options: new_resource.client_options,
              mysqld_safe_socket: new_resource.mysqld_safe_socket,
              mysqld_safe_nice: new_resource.mysqld_safe_nice,
              mysqld_safe_options: new_resource.mysqld_safe_options,
              mysqld_user: new_resource.mysqld_user,
              mysqld_pid_file: new_resource.mysqld_pid_file,
              mysqld_socket: new_resource.mysqld_socket,
              mysqld_port: new_resource.mysqld_port,
              mysqld_basedir: new_resource.mysqld_basedir,
              mysqld_datadir: new_resource.mysqld_datadir,
              mysqld_tmpdir: new_resource.mysqld_tmpdir,
              mysqld_lc_messages_dir: new_resource.mysqld_lc_messages_dir,
              mysqld_lc_messages: new_resource.mysqld_lc_messages,
              mysqld_skip_external_locking: new_resource.mysqld_skip_external_locking,
              mysqld_skip_log_bin: new_resource.mysqld_skip_log_bin,
              mysqld_skip_name_resolve: new_resource.mysqld_skip_name_resolve,
              mysqld_bind_address: new_resource.mysqld_bind_address,
              mysqld_max_connections: new_resource.mysqld_max_connections,
              mysqld_max_statement_time: new_resource.mysqld_max_statement_time,
              mysqld_connect_timeout: new_resource.mysqld_connect_timeout,
              mysqld_wait_timeout: new_resource.mysqld_wait_timeout,
              mysqld_max_allowed_packet: new_resource.mysqld_max_allowed_packet,
              mysqld_thread_cache_size: new_resource.mysqld_thread_cache_size,
              mysqld_sort_buffer_size: new_resource.mysqld_sort_buffer_size,
              mysqld_bulk_insert_buffer_size: new_resource.mysqld_bulk_insert_buffer_size,
              mysqld_tmp_table_size: new_resource.mysqld_tmp_table_size,
              mysqld_max_heap_table_size: new_resource.mysqld_max_heap_table_size,
              mysqld_myisam_recover: new_resource.mysqld_myisam_recover,
              mysqld_key_buffer_size: new_resource.mysqld_key_buffer_size,
              mysqld_open_files_limit: new_resource.mysqld_open_files_limit,
              mysqld_table_open_cache: new_resource.mysqld_table_open_cache,
              mysqld_myisam_sort_buffer_size: new_resource.mysqld_myisam_sort_buffer_size,
              mysqld_concurrent_insert: new_resource.mysqld_concurrent_insert,
              mysqld_read_buffer_size: new_resource.mysqld_read_buffer_size,
              mysqld_read_rnd_buffer_size: new_resource.mysqld_read_rnd_buffer_size,
              mysqld_query_cache_limit: new_resource.mysqld_query_cache_limit,
              mysqld_query_cache_size: new_resource.mysqld_query_cache_size,
              mysqld_query_cache_type: new_resource.mysqld_query_cache_type,
              mysqld_default_storage_engine: new_resource.mysqld_default_storage_engine,
              mysqld_general_log_file: new_resource.mysqld_general_log_file,
              mysqld_general_log: new_resource.mysqld_general_log,
              mysqld_log_warnings: new_resource.mysqld_log_warnings,
              mysqld_slow_query_log: new_resource.mysqld_slow_query_log,
              mysqld_slow_query_log_file: new_resource.mysqld_slow_query_log_file,
              mysqld_long_query_time: new_resource.mysqld_long_query_time,
              mysqld_log_slow_rate_limit: new_resource.mysqld_log_slow_rate_limit,
              mysqld_log_slow_verbosity: new_resource.mysqld_log_slow_verbosity,
              mysqld_log_output: new_resource.mysqld_log_output,
              mysqld_options: new_resource.mysqld_options,
              mysqldump_quick: new_resource.mysqldump_quick,
              mysqldump_quote_names: new_resource.mysqldump_quote_names,
              mysqldump_max_allowed_packet: new_resource.mysqldump_max_allowed_packet,
              mysqldump_options: new_resource.mysqldump_options,
              isamchk_key_buffer: new_resource.isamchk_key_buffer,
              isamchk_options: new_resource.isamchk_options,
              extra_configuration_directory: new_resource.extra_configuration_directory
             )
  end

  directory ext_conf_dir do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  directory new_resource.mysqld_log_directory do
    owner 'root'
    group 'mysql'
    mode '0770'
    action :create
  end

  mariadb_configuration '20-innodb' do
    section 'mysqld'
    cookbook new_resource.cookbook
    option build_innodb_options
    action :add
  end

  mariadb_configuration '30-replication' do
    section 'mysqld'
    cookbook new_resource.cookbook
    option build_replication_options
    action :add
  end

  ruby_block 'move_data_dir_if_needed' do
    block do
      move_data_dir
    end
    only_if { new_resource.mysqld_datadir != data_dir }
    not_if { ::File.symlink?(data_dir) }
  end

  ruby_block 'restart_mariadb_if_needed' do
    block do
      restart_mariadb_service
    end
    not_if { port_open?(new_resource.mysqld_bind_address, new_resource.mysqld_port) }
  end
end

action_class do
  include MariaDBCookbook::Helpers

  def build_innodb_options
    innodb_options = {}
    innodb_options['comment1']                      = '#'
    innodb_options['comment2']                      = '# * InnoDB'
    innodb_options['comment3']                      = '#'
    innodb_options['comment4']                      = '# InnoDB is enabled by default with a 10MB datafile in /var/lib/mysql/.'
    innodb_options['comment5']                      = '# Read the manual for more InnoDB related options. There are many!'
    innodb_options['innodb_log_file_size_comment1'] = '# you can\'t just change log file size, it requires special procedure'
    innodb_options['innodb_log_file_size']   = new_resource.innodb_log_file_size
    innodb_options['innodb_log_buffer_size'] = new_resource.innodb_log_buffer_size
    innodb_options['innodb_file_per_table']  = new_resource.innodb_file_per_table
    innodb_options['innodb_open_files']      = new_resource.innodb_open_files
    innodb_options['innodb_io_capacity']     = new_resource.innodb_io_capacity
    innodb_options['innodb_flush_method']    = new_resource.innodb_flush_method
    innodb_options['innodb_buffer_pool_size'] = if new_resource.innodb_bps_percentage_memory
                                                  (
                                                    new_resource.innodb_buffer_pool_size.to_f *
                                                    (node['memory']['total'][0..-3].to_i / 1024)
                                                  ).round.to_s + 'M'
                                                else
                                                  new_resource.innodb_buffer_pool_size
                                                end
    new_resource.innodb_options.each do |key, value|
      innodb_options[key] = value
    end
    innodb_options
  end

  def build_replication_options
    replication_opts = {}
    unless new_resource.replication_log_bin.nil?
      replication_opts['log_bin']          = new_resource.replication_log_bin
      replication_opts['sync_binlog']      = new_resource.replication_sync_binlog
      replication_opts['log_bin_index']    = new_resource.replication_log_bin_index
      replication_opts['expire_logs_days'] = new_resource.replication_expire_logs_days
      replication_opts['max_binlog_size']  = new_resource.replication_max_binlog_size
    end
    unless new_resource.replication_server_id.nil?
      replication_opts['server_id'] = new_resource.replication_server_id
    end
    new_resource.replication_options.each do |key, value|
      replication_opts[key] = value
    end
    replication_opts
  end

  def move_data_dir
    bash 'move-datadir' do
      user 'root'
      code <<-EOH
      /bin/cp -a #{data_dir}/* #{new_resource.mysqld_datadir} &&
      /bin/rm -rf #{data_dir} &&
      /bin/ln -s #{new_resource.mysqld_datadir} #{data_dir}
      EOH
      action :nothing
    end

    # Using this to generate a service resource to control
    service platform_service_name do
      supports restart: true, status: true, reload: true
      action :nothing
    end

    directory new_resource.mysqld_datadir do
      owner 'mysql'
      group 'mysql'
      mode '0750'
      action :create
      notifies :stop, "service[#{platform_service_name}]", :immediately
      notifies :run, 'bash[move-datadir]', :immediately
      notifies :start, "service[#{platform_service_name}]", :immediately
      not_if { ::File.symlink?(data_dir) }
    end
  end
end
