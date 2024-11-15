describe command('/usr/bin/mysql --help') do
  its('exit_status') { should eq 0 }
end

version = file('/tmp/mariadb_version').content

describe command('/usr/bin/mysql -V') do
  case version.to_i
  when 11
    its('stdout') { should match(/mysql from #{version}\.\d+-MariaDB, client 15.2/) }
  else
    its('stdout') { should match(%r{\/usr\/bin\/mysql  Ver 15\.1 Distrib #{version}\.\d+-MariaDB}) }
  end
  its('exit_status') { should eq 0 }
end
