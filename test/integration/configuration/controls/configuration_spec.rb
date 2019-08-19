# frozen_string_literal: true

# includedir = '/etc/mysql/conf.d'
extra_config_file = '/etc/mysql/conf.d/extra_innodb.cnf'
case os[:family]
when 'centos', 'redhat', 'amazon'
  # includedir = '/etc/my.cnf.d'
  extra_config_file = '/etc/my.cnf.d/extra_innodb.cnf'
end

{
  innodb_thread_concurrency: '8',
  innodb_commit_concurrency: '8',
  innodb_read_io_threads: '8',
  innodb_flush_log_at_trx_commit: '1',
}.each do |attribute, value|
  describe command("grep -E \"^#{attribute}\\s+\" #{extra_config_file}") do
    its(:stdout) { should match(/#{value}/) }
  end
end
