require 'spec_helper'

describe 'centos::mariadb::default' do
  cached(:chef_run) do
    runner = ChefSpec::ServerRunner.new(
      platform: 'centos', version: '6.4',
      step_into: ['mariadb_configuration']
    ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::default')
  end

  it 'Include recipe to choose repository' do
    expect(chef_run).to include_recipe('mariadb::_mariadb_repository')
  end

  it 'Include server recipe' do
    expect(chef_run).to include_recipe('mariadb::server')
  end

  it 'Include redhat recipe' do
    expect(chef_run).to include_recipe('mariadb::_redhat_server')
  end

  it 'Installs Mariadb-server package' do
    expect(chef_run).to install_package('MariaDB-server')
  end

  it 'Configure includedir in /etc/my.cnf' do
    expect(chef_run).to create_template('/etc/my.cnf')
    expect(chef_run).to render_file('/etc/my.cnf')
      .with_content(%r{/etc/my.cnf.d})
  end

  it 'Configure replication in /etc/my.cnf.d/30-replication.cnf' do
    expect(chef_run).to create_template('/etc/my.cnf.d/30-replication.cnf')
    expect(chef_run).to render_file('/etc/my.cnf.d/30-replication.cnf')
  end

  it 'Configure InnoDB with attributes' do
    expect(chef_run).to add_mariadb_configuration('20-innodb')
    expect(chef_run).to render_file('/etc/my.cnf.d/20-innodb.cnf')
      .with_content(/innodb_buffer_pool_size = 256M/)
    expect(chef_run).to create_template('/etc/my.cnf.d/20-innodb.cnf')
      .with(
        user:  'root',
        group: 'mysql',
        mode:  '0640'
      )
  end

  it 'Configure Replication' do
    expect(chef_run).to add_mariadb_configuration('30-replication')
  end

  it 'Create Log directory' do
    directory_log = chef_run.directory('/var/log/mysql')
    first_run_block = chef_run.ruby_block('MariaDB first start')
    expect(directory_log).to do_nothing
    expect(first_run_block).to do_nothing
    expect(first_run_block).to notify('directory[/var/log/mysql]')
      .to(:create)
      .immediately
  end

  it 'Enable and start MariaDB service' do
    server_package = chef_run.package('MariaDB-server')
    first_run_block = chef_run.ruby_block('MariaDB first start')
    expect(server_package).to notify('service[mysql]')
      .to(:enable)
    expect(first_run_block).to notify('service[mysql]')
      .to(:start)
      .immediately
  end

  it 'Don t execute root password change at install' do
    expect(chef_run).to_not run_execute('change first install root password')
  end

  context 'Installation with alternative data directory' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '7.0',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['install']['prefer_os_package'] = true
        node.override['mariadb']['mysqld']['datadir'] = '/home/mysql'
      end
      runner.converge('mariadb::default')
    end

    it 'Create data directory' do
      data_directory = chef_run.directory('/home/mysql')
      expect(chef_run).to create_directory('/home/mysql')
      expect(data_directory).to notify('service[mysql]')
        .to(:stop)
        .immediately
      expect(data_directory).to notify('bash[move-datadir]')
        .to(:run)
        .immediately
      expect(data_directory).to notify('service[mysql]')
        .to(:start)
        .immediately
    end

    it 'Move data directory' do
      move_datadir_block = chef_run.bash('move-datadir')
      expect(move_datadir_block).to do_nothing
    end

    it 'Restore security context' do
      restore_security_context = chef_run.bash('Restore security context')
      expect(restore_security_context).to do_nothing
      expect(restore_security_context).to subscribe_to('bash[move-datadir]')
        .on(:run)
        .immediately
    end
  end

  context 'Installation from MariaDB repository' do
    let(:mariadb_package) { chef_run.package('MariaDB-server') }
    let(:mariadb_service) { chef_run.service('mysql') }

    it 'Include MariaDB repository recipe' do
      expect(chef_run).to include_recipe('mariadb::repository')
    end

    it 'Installs Mariadb-shared package' do
      expect(chef_run).to install_package('MariaDB-shared')
    end

    it 'MariaDB service with the correct name' do
      expect(mariadb_service.service_name).to eq 'mysql'
    end

    it 'Package with the correct name' do
      expect(mariadb_package.package_name).to eq 'MariaDB-server'
    end
  end

  context 'Installation from OS repository' do
    cached(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '7.0',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['install']['prefer_os_package'] = true
      end
      runner.converge('mariadb::default')
    end
    let(:mariadb_package) { chef_run.package('MariaDB-server') }
    let(:mariadb_service) { chef_run.service('mysql') }

    it 'MariaDB service with the correct name' do
      expect(mariadb_service.service_name).to eq 'mariadb'
    end

    it 'Package with the correct name' do
      expect(mariadb_package.package_name).to eq 'mariadb-server'
    end
  end

  context 'Installation from SCL repository' do
    cached(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '7.0',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['install']['prefer_scl_package'] = true
      end
      runner.converge('mariadb::default')
    end
    let(:mariadb_package) { chef_run.package('MariaDB-server') }
    let(:mariadb_service) { chef_run.service('mysql') }

    it 'Include scl recipe' do
      expect(chef_run).to include_recipe('yum-scl::default')
    end

    context 'MariaDB 10.0' do
      it 'MariaDB service with the correct name' do
        expect(mariadb_service.service_name).to eq 'rh-mariadb100-mariadb'
      end

      it 'Package with the correct name' do
        expect(mariadb_package.package_name).to eq 'rh-mariadb100-mariadb-server'
      end
    end

    context 'MariaDB 5.5' do
      cached(:chef_run) do
        runner = ChefSpec::ServerRunner.new(
          platform: 'centos', version: '7.0',
          step_into: ['mariadb_configuration']
        ) do |node|
          node.automatic['memory']['total'] = '2048kB'
          node.automatic['ipaddress'] = '1.1.1.1'
          node.override['mariadb']['install']['prefer_scl_package'] = true
          node.override['mariadb']['install']['version'] = '5.5'
        end
        runner.converge('mariadb::default')
      end
      let(:mariadb_package) { chef_run.package('MariaDB-server') }
      let(:mariadb_service) { chef_run.service('mysql') }

      it 'MariaDB service with the correct name' do
        expect(mariadb_service.service_name).to eq 'mariadb55-mariadb'
      end

      it 'Package with the correct name' do
        expect(mariadb_package.package_name).to eq 'mariadb55-mariadb-server'
      end
    end

    context 'MariaDB 10.1' do
      cached(:chef_run) do
        runner = ChefSpec::ServerRunner.new(
          platform: 'centos', version: '7.0',
          step_into: ['mariadb_configuration']
        ) do |node|
          node.automatic['memory']['total'] = '2048kB'
          node.automatic['ipaddress'] = '1.1.1.1'
          node.override['mariadb']['install']['prefer_scl_package'] = true
          node.override['mariadb']['install']['version'] = '10.1'
        end
        runner.converge('mariadb::default')
      end
      let(:mariadb_package) { chef_run.package('MariaDB-server') }
      let(:mariadb_service) { chef_run.service('mysql') }

      it 'MariaDB service with the correct name' do
        expect(mariadb_service.service_name).to eq 'rh-mariadb101-mariadb'
      end

      it 'Package with the correct name' do
        expect(mariadb_package.package_name).to eq 'rh-mariadb101-mariadb-server'
      end
    end
  end
end

describe 'centos::mariadb::client' do
  cached(:chef_run) do
    runner = ChefSpec::ServerRunner.new(
      platform: 'centos', version: '6.4',
      step_into: ['mariadb_configuration']
    ) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::client')
  end

  it 'Include RH specific recipe' do
    expect(chef_run).to include_recipe('mariadb::_redhat_client')
  end

  it 'Include recipe to choose repository' do
    expect(chef_run).to include_recipe('mariadb::_mariadb_repository')
  end

  it 'Install MariaDB Client Package' do
    expect(chef_run).to install_package('MariaDB-client')
  end

  it 'Install MariaDB Client Devel Package' do
    expect(chef_run).to install_package('MariaDB-devel')
  end

  it 'Include devel recipe' do
    expect(chef_run).to include_recipe('mariadb::devel')
  end

  context 'Installation from MariaDB repository' do
    let(:mariadb_client_package) { chef_run.package('MariaDB-client') }
    let(:mariadb_devel_package) { chef_run.package('MariaDB-devel') }

    it 'Include MariaDB repository recipe' do
      expect(chef_run).to include_recipe('mariadb::repository')
    end

    it 'Remove mysql-libs package' do
      expect(chef_run).to remove_package('mysql-libs')
    end

    it 'Packages with the correct name' do
      expect(mariadb_client_package.package_name).to eq 'MariaDB-client'
      expect(mariadb_devel_package.package_name).to eq 'MariaDB-devel'
    end
  end

  context 'Installation from OS repository' do
    cached(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '7.0',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['install']['prefer_os_package'] = true
      end
      runner.converge('mariadb::client')
    end
    let(:mariadb_client_package) { chef_run.package('MariaDB-client') }
    let(:mariadb_devel_package) { chef_run.package('MariaDB-devel') }

    it 'Packages with the correct name' do
      expect(mariadb_client_package.package_name).to eq 'mariadb'
      expect(mariadb_devel_package.package_name).to eq 'mariadb-devel'
    end
  end

  context 'Installation from SCL repository (centos 6)' do
    cached(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '6.0',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['install']['prefer_scl_package'] = true
      end
      runner.converge('mariadb::client')
    end

    let(:mariadb_client_package) { chef_run.package('MariaDB-client') }
    let(:mariadb_devel_package) { chef_run.package('MariaDB-devel') }

    it 'Include SCL repository recipe' do
      expect(chef_run).to include_recipe('yum-scl::default')
    end

    it 'Remove mysql-libs package' do
      expect(chef_run).to remove_package('mysql-libs')
    end

    context 'MariaDB 10.0' do
      it 'Packages with the correct name' do
        expect(mariadb_client_package.package_name).to eq 'rh-mariadb100-mariadb'
        expect(mariadb_devel_package.package_name).to eq 'rh-mariadb100-mariadb-devel'
      end
    end

    context 'MariaDB 5.5' do
      cached(:chef_run) do
        runner = ChefSpec::ServerRunner.new(
          platform: 'centos', version: '6.0',
          step_into: ['mariadb_configuration']
        ) do |node|
          node.automatic['memory']['total'] = '2048kB'
          node.automatic['ipaddress'] = '1.1.1.1'
          node.override['mariadb']['install']['prefer_scl_package'] = true
          node.override['mariadb']['install']['version'] = '5.5'
        end
        runner.converge('mariadb::client')
      end

      it 'Packages with the correct name' do
        expect(mariadb_client_package.package_name).to eq 'mariadb55-mariadb'
        expect(mariadb_devel_package.package_name).to eq 'mariadb55-mariadb-devel'
      end
    end

    context 'MariaDB 10.1' do
      cached(:chef_run) do
        runner = ChefSpec::ServerRunner.new(
          platform: 'centos', version: '6.0',
          step_into: ['mariadb_configuration']
        ) do |node|
          node.automatic['memory']['total'] = '2048kB'
          node.automatic['ipaddress'] = '1.1.1.1'
          node.override['mariadb']['install']['prefer_scl_package'] = true
          node.override['mariadb']['install']['version'] = '10.1'
        end
        runner.converge('mariadb::client')
      end
      it 'Packages with the correct name' do
        expect(mariadb_client_package.package_name).to eq 'rh-mariadb101-mariadb'
        expect(mariadb_devel_package.package_name).to eq 'rh-mariadb101-mariadb-devel'
      end
    end
  end

  context 'Installation from SCL repository (centos 7)' do
    cached(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '7.0',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['install']['prefer_scl_package'] = true
      end
      runner.converge('mariadb::client')
    end

    let(:mariadb_client_package) { chef_run.package('MariaDB-client') }
    let(:mariadb_devel_package) { chef_run.package('MariaDB-devel') }

    it 'Include SCL repository recipe' do
      expect(chef_run).to include_recipe('yum-scl::default')
    end

    it 'Remove mysql-libs package' do
      expect(chef_run).to_not remove_package('mysql-libs')
    end

    context 'MariaDB 10.0' do
      it 'Packages with the correct name' do
        expect(mariadb_client_package.package_name).to eq 'rh-mariadb100-mariadb'
        expect(mariadb_devel_package.package_name).to eq 'rh-mariadb100-mariadb-devel'
      end
    end

    context 'MariaDB 5.5' do
      cached(:chef_run) do
        runner = ChefSpec::ServerRunner.new(
          platform: 'centos', version: '7.0',
          step_into: ['mariadb_configuration']
        ) do |node|
          node.automatic['memory']['total'] = '2048kB'
          node.automatic['ipaddress'] = '1.1.1.1'
          node.override['mariadb']['install']['prefer_scl_package'] = true
          node.override['mariadb']['install']['version'] = '5.5'
        end
        runner.converge('mariadb::client')
      end

      it 'Packages with the correct name' do
        expect(mariadb_client_package.package_name).to eq 'mariadb55-mariadb'
        expect(mariadb_devel_package.package_name).to eq 'mariadb55-mariadb-devel'
      end
    end

    context 'MariaDB 10.1' do
      cached(:chef_run) do
        runner = ChefSpec::ServerRunner.new(
          platform: 'centos', version: '7.0',
          step_into: ['mariadb_configuration']
        ) do |node|
          node.automatic['memory']['total'] = '2048kB'
          node.automatic['ipaddress'] = '1.1.1.1'
          node.override['mariadb']['install']['prefer_scl_package'] = true
          node.override['mariadb']['install']['version'] = '10.1'
        end
        runner.converge('mariadb::client')
      end
      it 'Packages with the correct name' do
        expect(mariadb_client_package.package_name).to eq 'rh-mariadb101-mariadb'
        expect(mariadb_devel_package.package_name).to eq 'rh-mariadb101-mariadb-devel'
      end
    end
  end

  context 'Without development files' do
    cached(:chef_run) do
      runner = ChefSpec::ServerRunner.new(
        platform: 'centos', version: '6.4',
        step_into: ['mariadb_configuration']
      ) do |node|
        node.automatic['memory']['total'] = '2048kB'
        node.automatic['ipaddress'] = '1.1.1.1'
        node.override['mariadb']['client']['development_files'] = false
      end
      runner.converge('mariadb::client')
    end

    it 'Don t install MariaDB Client Devel Package' do
      expect(chef_run).to_not install_package('MariaDB-devel')
    end
  end
end
