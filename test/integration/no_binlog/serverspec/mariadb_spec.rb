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

describe "verify that bin_log is not set in #{mysql_config_file}" do
  describe command('grep -E "^log_bin\\s+" ' + mysql_config_file) do
    its(:exit_status) { should eq 1 }
  end
end

describe 'verify that bin_log is not set in ' + includedir + '/replication.cnf' do
  describe command('grep -E "^log_bin\\s+" ' + includedir + '/replication.cnf') do
    its(:exit_status) { should eq 1 }
  end
end

# describe command('/usr/bin/mysql -BN -e"SHOW GLOBAL VARIABLES ' \
#                  'LIKE \'log_bin\';" | cut -f 2') do
#   its(:stdout) { should match 'OFF' }
# end
