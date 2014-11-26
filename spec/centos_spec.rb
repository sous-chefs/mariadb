require 'spec_helper'

describe 'centos::mariadb::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
                                   platform: 'centos', version: '6.4',
                                   step_into: ['mariadb_configuration']
                                 ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::default')
  end

  it 'Installs Mariadb package' do
    expect(chef_run).to install_package('MariaDB-server')
  end

  it 'Configure includedir in /etc/my.cnf' do
    expect(chef_run).to create_template('/etc/my.cnf')
    expect(chef_run).to render_file('/etc/my.cnf')
      .with_content(%r{/etc/my.cnf.d})
  end

  it 'Configure replication in /etc/my.cnf.d/replication.cnf' do
    expect(chef_run).to create_template('/etc/my.cnf.d/replication.cnf')
    expect(chef_run).to render_file('/etc/my.cnf.d/replication.cnf')
  end

  it 'Configure InnoDB with attributes' do
    expect(chef_run).to add_mariadb_configuration('innodb')
    expect(chef_run).to render_file('/etc/my.cnf.d/innodb.cnf')
      .with_content(/innodb_buffer_pool_size = 256M/)
    expect(chef_run).to create_template('/etc/my.cnf.d/innodb.cnf')
      .with(
        user:  'root',
        group: 'mysql',
        mode:  '0640'
      )
  end

  it 'Configure Replication' do
    expect(chef_run).to add_mariadb_configuration('replication')
  end

  it 'Don t execute root password change at install' do
    expect(chef_run).to_not run_execute('change first install root password')
  end

  it 'Create Log directory' do
    directory_log = chef_run.directory('/var/log/mysql')
    expect(directory_log).to do_nothing
    resource = chef_run.package('MariaDB-server')
    expect(resource).to notify('directory[/var/log/mysql]')
      .to(:create)
      .immediately
  end
end

describe 'centos::mariadb::client' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
                                   platform: 'centos', version: '6.4',
                                   step_into: ['mariadb_configuration']
                                 ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::client')
  end

  it 'Remove mysql-libs package' do
    expect(chef_run).to remove_package('mysql-libs')
  end

  it 'Install MariaDB Client Package' do
    expect(chef_run).to install_package('MariaDB-client')
  end

  it 'Install MariaDB Client Devel Package' do
    expect(chef_run).to install_package('MariaDB-devel')
  end
  context 'Without development files' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(
                                     platform: 'centos', version: '6.4',
                                     step_into: ['mariadb_configuration']
                                   ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.set['mariadb']['client']['development_files'] = false
      end
      runner.converge('mariadb::client')
    end

    it 'Install MariaDB Client Package' do
      expect(chef_run).to install_package('MariaDB-client')
    end

    it 'Don t install MariaDB Client Devel Package' do
      expect(chef_run).to_not install_package('MariaDB-devel')
    end
  end
end
