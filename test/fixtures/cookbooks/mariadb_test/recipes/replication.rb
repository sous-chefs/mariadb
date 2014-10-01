include_recipe 'mariadb::server'

%w(server1 server2 server3).each do |name|
  mariadb_replication name do
    action :add
    master_user 'slave_replication'
    master_password '@lph0ns3'
    master_host '1.1.1.1'
    master_use_gtid 'current_pos'
  end
end
