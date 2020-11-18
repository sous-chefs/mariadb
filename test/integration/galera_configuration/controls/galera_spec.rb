include_dir = '/etc/mysql/conf.d'
include_dir = '/etc/my.cnf.d' if os.family == 'redhat'

galera_config_file = "#{include_dir}/90-galera.cnf"
ip_address = sys_info.ip_address.strip

control 'mariadb_galera_configuration' do
  impact 1.0
  title 'test global installation when galera configuration'

  describe service('mysql') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port('3306') do
    it { should be_listening }
  end
end

control 'mariadb_galera_configuration' do
  impact 1.0
  title "verify the rendered config in #{galera_config_file}"

  content = <<-EOF.gsub(/^\s+/, '')
    # DEPLOYED BY CHEF
    [mysqld]
    query_cache_size = 0
    binlog_format = ROW
    default_storage_engine = InnoDB
    innodb_autoinc_lock_mode = 2
    innodb_doublewrite = 1
    server_id = 100
    innodb_flush_log_at_trx_commit = 2
    wsrep_on = ON
    wsrep_provider_options = "gcache.size=512M"
    wsrep_cluster_address = gcomm://
    wsrep_cluster_name = galera_cluster
    wsrep_sst_method = mariabackup
    wsrep_sst_auth = sstuser:some_secret_password
    wsrep_provider = /usr/lib/galera/libgalera_smm.so
    wsrep_slave_threads = 8
    wsrep_node_address = #{ip_address}
  EOF

  describe file(galera_config_file) do
    its('content') { should eq content }
  end
end
