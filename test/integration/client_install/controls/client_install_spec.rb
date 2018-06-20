describe command('/usr/bin/mysql --help') do
  its('exit_status') { should eq 0 }
end

describe command('/usr/bin/mysql -V') do
  its('stdout') { should match(/\/usr\/bin\/mysql  Ver 15\.1 Distrib 10\.3\.[0-9]+-MariaDB, for [A-Za-z0-9-]+inux[A-Za-z0-9\-]* \(x86_64\) using readline 5\.[1-2]/) }
  its('exit_status') { should eq 0 }
end
