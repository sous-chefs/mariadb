require 'spec_helper'

describe service('mysql') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port('3306') do
  it { should be_listening }
end

mysql_config_file = if %w(fedora centos redhat).include?(os[:family])
                      '/etc/my.cnf'
                    else
                      '/etc/mysql/my.cnf'
                    end

describe "verify the sst attribues set in #{mysql_config_file}" do
  {
    tkey: '/etc/mysql/server-key.pem',
    tcert: '/etc/mysql/server-cert.pem',
    encrypt: '3'
  }.each do |attribute, value|
    describe command("grep -E \"^#{attribute}\\s+\" #{mysql_config_file}") do
      its(:stdout) { should match(/#{value}/) }
    end
  end
end
