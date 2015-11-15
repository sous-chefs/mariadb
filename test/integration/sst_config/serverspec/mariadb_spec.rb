require 'spec_helper'

describe service('mysql') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port('3306') do
  it { should be_listening }
end

includedir = '/etc/mysql/conf.d'
mysql_config_file = '/etc/mysql/my.cnf'
case os[:family]
when 'fedora', 'centos', 'redhat'
  includedir = '/etc/my.cnf.d'
  mysql_config_file = '/etc/my.cnf'
end

describe "verify the sst attribues set in #{mysql_config_file}" do
  {

    tkey: '/etc/mysql/server-key.pem',
    tcert: '/etc/mysql/server-cert.pem',
    encrypt: '3'

  }.each do |attribute, value|
    describe command("grep -E \"^#{attribute}\\s+\" #{mysql_config_file}") do
      its(:stdout)  { should match(/#{value}/) }
    end
  end
end

# describe 'verify the tuning attributes set in ' + includedir + '/innodb.cnf' do
#   {
#     innodb_buffer_pool_size: '256M',
#     innodb_flush_method: 'O_DIRECT',
#     innodb_file_per_table: 1,
#     innodb_open_files: 400
#   }.each do |attribute, value|
#     describe command("grep -E \"^#{attribute}\\s+\" " \
#                      "#{includedir}/innodb.cnf") do
#       its(:stdout) { should match(/#{value}/) }
#     end
#   end
# end

# describe 'verify the tuning attributes set in ' + includedir + '/replication.cnf' do
#   {
#     max_binlog_size: '100M',
#     expire_logs_days: 10
#   }.each do |attribute, value|
#     describe command("grep -E \"^#{attribute}\\s+\" " \
#                      "#{includedir}/replication.cnf") do
#       its(:stdout) { should match(/#{value}/) }
#     end
#   end
# end
