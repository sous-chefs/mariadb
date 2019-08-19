# mariadb_server_configuration

## Actions

- `modify` - (default) Maintain the configuration file

## Properties

Name                            | Types             | Description                                                   | Default                                          | Required?
------------------------------- | ----------------- | ------------------------------------------------------------- | ------------------------------------------------ | ---------
`version`                       | String            | Version of MariaDB installed                                  | `10.3`                                           | no
`cookbook`                      | String            |                                                               | `mariadb`                                        | no
`mycnf_file`                    | String            |                                                               | `"#{conf_dir}my.cnf"` (1)                        | no
`extra_configuration_directory` | String,           |                                                               | `ext_conf_dir` (2)                               | no
`client_port`                   | String, Integer   |                                                               | `3306`                                           | no
`client_socket`                 | String            |                                                               | `default_socket` (3)                             | no
`client_host`                   | String, nil       |                                                               | `nil`                                            | no
`client_options`                | Hash              |                                                               | `{}`                                             | no
`mysqld_safe_socket`            | String            |                                                               | `default_socket` (3)                             | no
`mysqld_safe_nice`              | String, Integer   |                                                               | `0`                                              | no
`mysqld_safe_options`           | Hash              |                                                               | `{}`                                             | no
`mysqld_user`                   | String            |                                                               | `mysql`                                          | no
`mysqld_pid_file`               | String, nil       |                                                               | `default_pid_file` (4)                           | no
`mysqld_socket`                 | String            |                                                               | `default_socket` (3)                             | no
`mysqld_basedir`                | String            |                                                               | `/usr`                                           | no
`mysqld_datadir`                | String            |                                                               | `/var/lib/mysql`                                 | no
`mysqld_tmpdir`                 | String            |                                                               | `/var/tmp`                                       | no
`mysqld_lc_messages_dir`        | String            |                                                               | `/usr/share/mysql`                               | no
`mysqld_lc_messages`            | String            |                                                               | `en_US`                                          | no
`mysqld_skip_external_locking`  | Boolean           |                                                               | `true`                                           | no
`mysqld_skip_log_bin`           | Boolean           |                                                               | `false`                                          | no
`mysqld_skip_name_resolve`      | Boolean           |                                                               | `false`                                          | no
`mysqld_bind_address`           | String            |                                                               | `127.0.0.1`                                      | no
`mysqld_port`                   | String, Integer   |                                                               | `3306`                                           | no
`mysqld_max_connections`        | Integer           |                                                               | `100`                                            | no
`mysqld_max_statement_time`     | Integer, nil      |                                                               | `nil`                                            | no
`mysqld_connect_timeout`        | Integer           |                                                               | `5`                                              | no
`mysqld_wait_timeout`           | Integer           |                                                               | `600`                                            | no
`mysqld_max_allowed_packet`     | String            |                                                               | `16M`                                            | no
`mysqld_thread_cache_sizer`     | Integer           |                                                               | `128`                                            | no
`mysqld_sort_buffer_size`       | String            |                                                               | `4M`                                             | no
`mysqld_bulk_insert_buffer_size`| String            |                                                               | `16M`                                            | no
`mysqld_tmp_table_size`         | String            |                                                               | `32M`                                            | no
`mysqld_max_heap_table_size`    | String            |                                                               | `32M`                                            | no
`mysqld_myisam_recover`         | String            |                                                               | `BACKUP`                                         | no
`mysqld_key_buffer_size`        | String            |                                                               | `128M`                                           | no
`mysqld_open_files_limit`       | Integer, nil      |                                                               | `nil`                                            | no
`mysqld_table_open_cache`       | Integer           |                                                               | `400`                                            | no
`mysqld_myisam_sort_buffer_size`| String            |                                                               | `512M`                                           | no
`mysqld_concurrent_insert`      | Integer           |                                                               | `2`                                              | no
`mysqld_read_buffer_size`       | String            |                                                               | `2M`                                             | no
`mysqld_read_rnd_buffer_size`   | String            |                                                               | `1M`                                             | no
`mysqld_query_cache_limit`      | String            |                                                               | `128K`                                           | no
`mysqld_query_cache_size`       | String            |                                                               | `64M`                                            | no
`mysqld_query_cache_type`       | String, nil       |                                                               | `nil`                                            | no
`mysqld_default_storage_engine` | String            |                                                               | `InnoDB`                                         | no
`mysqld_log_directory`          | String            |                                                               | `/var/log/mysql`                                 | no
`mysqld_general_log_file`       | String            |                                                               | `"#{mysqld_log_directory}/mysql.log"` (5)        | no
`mysqld_general_log`            | Integer           |                                                               | `0`                                              | no
`mysqld_log_warnings`           | Integer           |                                                               | `2`                                              | no
`mysqld_slow_query_log`         | Integer           |                                                               | `0`                                              | no
`mysqld_slow_query_log_file`    | String            |                                                               | `"#{mysqld_log_directory}/mariadb-slow.log"` (5) | no
`mysqld_long_query_time`        | Integer           |                                                               | `10`                                             | no
`mysqld_log_slow_rate_limit`    | Integer           |                                                               | `1000`                                           | no
`mysqld_log_slow_verbosity`     | String            |                                                               | `query_plan`                                     | no
`mysqld_log_output`             | String            |                                                               | `'FILE`                                          | no
`mysqld_options`                | Hash              |                                                               | `{}`                                             | no
`mysqldump_quick`               | Boolean           |                                                               | `true`                                           | no
`mysqldump_quote_names`         | Boolean           |                                                               | `true`                                           | no
`mysqldump_max_allowed_packet`  | String            |                                                               | `16M`                                            | no
`mysqldump_options`             | Hash              |                                                               | `{}`                                             | no
`isamchk_key_buffer`            | String            |                                                               | `16M`                                            | no
`isamchk_options`               | Hash              |                                                               | `{}`                                             | no
`innodb_log_file_size`          | String            |                                                               | `50M`                                            | no
`innodb_bps_percentage_memory`  | Boolean           |                                                               | `false`                                          | no
`innodb_buffer_pool_size`       | String            |                                                               | `50M`                                            | no
`innodb_log_buffer_size`        | String            |                                                               | `8M`                                             | no
`innodb_file_per_table`         | Integer           |                                                               | `1`                                              | no
`innodb_open_files`             | Integer           |                                                               | `400`                                            | no
`innodb_io_capacity`            | Integer           |                                                               | `400`                                            | no
`innodb_flush_method`           | String            |                                                               | `O_DIRECT`                                       | no
`innodb_options`                | Hash              |                                                               | `{}`                                             | no
`replication_server_id`         | String, nil       |                                                               | `nil`                                            | no
`replication_log_bin`           | String,nil        |                                                               | `"#{mysqld_log_directory}/mariadb-bin"`(5)       | no
`replication_log_bin_index`     | String            |                                                               | `"#{mysqld_log_directory}/mariadb-bin.index"` (5)| no
`replication_sync_binlog`       | String, Integer   |                                                               | `0`                                              | no
`replication_expire_logs_days`  | Integer           |                                                               | `10`                                             | no
`replication_max_binlog_size`   | String            |                                                               | `100M`                                           | no
`replication_options`           | Hash              |                                                               | `{}`                                             | no

(1) `conf_dir` is a helper method which return the configuration directory based on OS flavor
(2) `ext_conf_dir` is a helper method which return the extra configuration directory based on OS flavor
(3) `default_socket` is a helper method which return the full socket path based on OS flavor
(4) `default_pid_file` is a helper method which return the pid file name and path based on OS flavor
(5) `mysqld_log_directory` is a helper method which return the log directory based on OS flavor

## Examples

```ruby
mariadb_server_configuration 'MariaDB Server Configuration' do
  version '10.3'
  client_host 'localhost'
end
```
