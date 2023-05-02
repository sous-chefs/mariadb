# frozen_string_literal: true

version = file('/tmp/mariadb_version').content

describe command('mysqld -V') do
  its('stdout') { should match(/mysqld  Ver #{version}\.\d+-MariaDB/) }
  its('exit_status') { should eq 0 }
end

describe service('mysql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

include_controls 'client_install'
