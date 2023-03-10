describe command('/usr/bin/mysql --help') do
  its('exit_status') { should eq 0 }
end

describe command('/usr/bin/mysql -V') do
  # Each stock distro package has a different version
  its('exit_status') { should eq 0 }
end

# Ensure it does not install the server
describe service('mysqld') do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end
