require 'spec_helper'
describe 'debian::mariadb::client' do
  cached(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'debian', version: '7.4',
      step_into: ['mariadb_configuration']
    ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::client')
  end

  it 'Install MariaDB Client Package' do
    expect(chef_run).to install_package('mariadb-client-10.0')
  end

  it 'Install MariaDB Client Devel Package' do
    expect(chef_run).to install_package('libmariadbclient-dev')
  end
  context 'Without development files' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'debian', version: '7.4',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['client']['development_files'] = false
      end
      runner.converge('mariadb::client')
    end

    it 'Install MariaDB Client Package' do
      expect(chef_run).to install_package('mariadb-client-10.0')
    end

    it 'Don t install MariaDB Client Devel Package' do
      expect(chef_run).to_not install_package('libmariadbclient-dev')
    end
  end
end
