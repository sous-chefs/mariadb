describe command('/usr/bin/mysql --help') do
  its('exit_status') { should eq 0 }
end

version = file('/tmp/mariadb_version').content

describe command('/usr/bin/mysql -V') do
  its('stdout') { should match(%r{\/usr\/bin\/mysql  Ver 15\.1 Distrib #{version}\.\d+-MariaDB}) }
  its('exit_status') { should eq 0 }
end
