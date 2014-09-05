require 'spec_helper'

at_exit { ChefSpec::Coverage.report! }

describe 'centos::mariadb::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(platform: 'centos', version: '6.4', step_into: ['mariadb_configuration']) do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::default')
  end

  it 'Installs Mariadb package' do
    expect(chef_run).to install_package('MariaDB-server')
  end

  it 'Configure includedir in /etc/my.cnf' do
    expect(chef_run).to render_file('/etc/my.cnf')
      .with_content(/\/etc\/my.cnf.d/)
  end

  it 'Configure replication in /etc/my.cnf.d/replication.cnf' do
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

end
