include_recipe 'mariadb::server'

mariadb_replication 'default' do
  action :add
  master_user 'slave_replication'
  master_password '@lph0ns3'
  master_host '1.1.1.100'
  master_use_gtid 'current_pos'
end

%w(1 2 3).each do |server_number|
  mariadb_replication "server#{server_number}" do
    action :add
    master_user 'slave_replication'
    master_password '@lph0ns3'
    master_host "1.1.1.#{server_number}"
    master_use_gtid 'current_pos'
  end
end
