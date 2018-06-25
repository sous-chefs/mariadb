# frozen_string_literal: true

# includedir = '/etc/mysql/conf.d'
mysql_config_file = '/etc/mysql/my.cnf'
case os[:family]
when 'centos', 'redhat', 'amazon'
  # includedir = '/etc/my.cnf.d'
  mysql_config_file = '/etc/my.cnf'
end

{
  query_cache_size: '64M',
  thread_cache_size: 128,
  max_connections: 100,
  wait_timeout: 600,
  max_heap_table_size: '32M',
  read_buffer_size: '2M',
  read_rnd_buffer_size: '1M',
  long_query_time: 10,
  key_buffer_size: '128M',
  max_allowed_packet: '16M',
  sort_buffer_size: '4M',
  myisam_sort_buffer_size: '512M',
}.each do |attribute, value|
  describe command("grep -E \"^#{attribute}\\s+\" #{mysql_config_file}") do
    its(:stdout) { should match(/#{value}/) }
  end
end
