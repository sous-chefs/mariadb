require 'spec_helper'

describe file('/etc/mysql/conf.d/innodb.cnf') do
  it { should be_file }
end

describe file('/etc/mysql/conf.d/replication.cnf') do
  it { should be_file }
end
