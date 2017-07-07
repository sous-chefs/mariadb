require 'spec_helper'

shared_examples 'MariaDB server installation' do
  it 'Include server recipes' do
    expect(chef_run).to include_recipe('mariadb::server')
  end

  it 'Configure MariaDB' do
    expect(chef_run).to create_template("#{mariadb_conf_attr('path')}/my.cnf")
    expect(chef_run).to render_file("#{mariadb_conf_attr('path')}/my.cnf")
  end

  it 'Configure includedir' do
    expect(chef_run).to render_file("#{mariadb_conf_attr('path')}/my.cnf")
      .with_content(/#{mariadb_conf_attr('includedir')}/)
  end

  it 'Configure replication' do
    expect(chef_run).to add_mariadb_configuration('30-replication')
    expect(chef_run).to create_template("#{mariadb_conf_attr('includedir')}/30-replication.cnf")
    expect(chef_run).to render_file("#{mariadb_conf_attr('includedir')}/30-replication.cnf")
  end

  it 'Configure InnoDB with attributes' do
    expect(chef_run).to add_mariadb_configuration('20-innodb')
    expect(chef_run).to render_file("#{mariadb_conf_attr('includedir')}/20-innodb.cnf")
      .with_content(/innodb_buffer_pool_size = 256M/)
    expect(chef_run).to create_template("#{mariadb_conf_attr('includedir')}/20-innodb.cnf")
      .with(
        user:  'root',
        group: 'mysql',
        mode:  '0640'
      )
  end

  it 'Enable and start MariaDB service' do
    server_package = chef_run.package('MariaDB-server')
    server_service = chef_run.service('mysql')
    expect(server_service).to do_nothing
    expect(server_package).to notify('service[mysql]')
      .to(:enable)
  end
  it 'Installs grants' do
    expect(chef_run.execute('install-grants')).to do_nothing
    expect(chef_run).to render_file('/etc/mariadb_grants')
    expect(chef_run).to create_template('/etc/mariadb_grants')
  end
end

shared_examples 'MariaDB Server with alternative datadir' do
  it 'Create data directory' do
    expect(chef_run).to create_directory(data_directory)
    expect(chef_run.directory(data_directory)).to notify('service[mysql]')
      .to(:stop)
      .immediately
    expect(chef_run.directory(data_directory)).to notify('bash[move-datadir]')
      .to(:run)
      .immediately
    expect(chef_run.directory(data_directory)).to notify('service[mysql]')
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

shared_examples 'MariaDB Server on RedHat' do
  it 'Create includedir' do
    expect(chef_run).to create_directory("#{mariadb_conf_attr('includedir')}/")
  end

  it 'Don t execute root password change at install' do
    expect(chef_run).to_not run_execute('change first install root password')
  end

  it 'Create Log directory' do
    directory_log = chef_run.directory('/var/log/mysql')
    expect(directory_log).to do_nothing
  end

  it 'First run' do
    first_run_block = chef_run.ruby_block('MariaDB first start')
    expect(first_run_block).to do_nothing
    expect(first_run_block).to notify('directory[/var/log/mysql]')
      .to(:create)
      .immediately
    expect(first_run_block).to notify('service[mysql]')
      .to(:start)
      .immediately
  end
end

shared_examples 'MariaDB Server on Debian' do
  it 'Include debian recipe' do
    expect(chef_run).to include_recipe('mariadb::_debian_server')
  end

  it 'Installs debconf-utils package' do
    expect(chef_run).to install_package('debconf-utils')
  end

  it 'Configure Preseeding' do
    expect(chef_run).to create_directory('/var/cache/local/preseeding')
    expect(chef_run).to create_template('/var/cache/local/' \
                                        'preseeding/mariadb-server.seed')
  end

  it 'execute preseeding load' do
    execute = chef_run.execute('preseed mariadb-server')
    expect(execute).to do_nothing
  end
end
