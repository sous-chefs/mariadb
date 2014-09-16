require 'spec_helper'

describe 'debian::mariadb::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
                                   platform: 'debian', version: '7.4',
                                   step_into: ['mariadb_configuration']
                                 ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::default')
  end

  it 'Configure includedir in /etc/mysql/my.cnf' do
    expect(chef_run).to create_template('/etc/mysql/my.cnf')
    expect(chef_run).to render_file('/etc/mysql/my.cnf')
      .with_content(%r{/etc/mysql/conf.d})
  end

  it 'Installs Mariadb package' do
    expect(chef_run).to install_package('mariadb-server-10.0')
  end

  it 'Configure InnoDB with attributes' do
    expect(chef_run).to add_mariadb_configuration('innodb')
    expect(chef_run).to render_file('/etc/mysql/conf.d/innodb.cnf')
      .with_content(/innodb_buffer_pool_size = 256M/)
    expect(chef_run).to create_template('/etc/mysql/conf.d/innodb.cnf')
      .with(
        user:  'root',
        group: 'mysql',
        mode:  '0640'
      )
  end

  it 'Configure Replication' do
    expect(chef_run).to add_mariadb_configuration('replication')
    expect(chef_run).to create_template('/etc/mysql/conf.d/replication.cnf')
  end

  it 'restart mysql service' do
    expect(chef_run).to restart_service('mysql')
  end

end

describe 'debian::mariadb::client' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
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
end
