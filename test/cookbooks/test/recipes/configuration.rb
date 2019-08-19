include_recipe 'test::server_install'

mariadb_configuration 'extra_innodb' do
  section 'mysqld'
  option innodb_thread_concurrency: 8,
         innodb_commit_concurrency: 8,
         innodb_read_io_threads: 8,
         innodb_flush_log_at_trx_commit: 1
end
