require 'spec_helper'

os = backend.check_os[:family]

includedir = '/etc/mysql/conf.d'
case os
when "Fedora" , "CentOS", "RedHat"
  includedir = '/etc/my.cnf.d'
end

describe file(includedir + '/innodb.cnf') do
  it { should be_file }
end

describe file(includedir + '/replication.cnf') do
  it { should be_file }
end
