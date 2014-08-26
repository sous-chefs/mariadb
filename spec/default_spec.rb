require 'spec_helper'

at_exit { ChefSpec::Coverage.report! }

describe 'mariadb::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(platform: 'debian', version: '7.4') do |node|
      node.automatic['memory']['total'] = '2048kB'
      node.automatic['ipaddress'] = '1.1.1.1'
    end
    runner.converge('mariadb::default')
  end

  it 'Installs Mariadb package' do
    expect(chef_run).to install_package('mariadb-server-10.0')
  end

  it 'Configure InnoDB with attributes' do
    expect(chef_run).to render_file('/etc/mysql/conf.d/innodb.cnf')
      .with_content(/innodb_buffer_pool_size = 256M/)
    expect(chef_run).to create_template('/etc/mysql/conf.d/innodb.cnf')
      .with(
        user:  'root',
        group: 'mysql',
        mode:  '0640'
      )
  end

end
