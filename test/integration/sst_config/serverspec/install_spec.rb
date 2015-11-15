require 'spec_helper'

package_server_name = 'mariadb-galera-server-10.0'
case os[:family]
when 'fedora', 'centos', 'redhat'
  package_server_name = 'MariaDB-Galera-server'
end

describe package(package_server_name) do
  it { should be_installed }
end
