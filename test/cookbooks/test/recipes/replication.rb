include_recipe 'test::server_configuration'

mariadb_replication 'default' do
  action :add
  password 'gsql'
  master_user 'slave_replication'
  master_password '@lph0ns3'
  master_host '1.1.1.100'
  master_use_gtid 'Current_Pos'
end

%w(1 2 3).each do |server_number|
  mariadb_replication "server#{server_number}" do
    action :add
    password 'gsql'
    master_user 'slave_replication'
    master_password '@lph0ns3'
    master_host "1.1.1.#{server_number}"
    master_use_gtid 'Current_Pos'
  end
end
