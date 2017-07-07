require 'chefspec'
require 'chefspec/berkshelf'

def mariadb_conf_attr(name)
  node[described_cookbook]['configuration'][name]
end

def mariadb_mysqld_attr(name)
  node[described_cookbook]['mysqld'][name]
end

def mariadb_client_attr(name)
  node[described_cookbook]['client'][name]
end

def mariadb_install_attr(name)
  node[described_cookbook]['install'][name]
end
RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
  config.alias_example_group_to :platform
  config.alias_example_group_to :platform_version
end


alternative_data_dir = '/home/mysql'

# Require all our libraries
Dir['libraries/*_helper.rb'].each { |f| require File.expand_path(f) }

shared_context 'MariaDB installation' do
  let(:node) do
    chef_run.node
  end

  let(:tcpsocket_obj) do
    double(
      'TCPSocket',
      close: true
    )
  end
  let(:node_attributes) do
    { }
  end
  let(:node_automatic_attributes) do
    { memory: { total: '2048kB'},
      'ipaddress' => '1.1.1.1' }
  end
  let(:node_override_attributes) do
    { }
  end
  cached(:chef_run) do
    runner = ChefSpec::SoloRunner.new(node_attributes) do |node|
      node.automatic.merge!(node_automatic_attributes)
      node.override.merge!(node_override_attributes)
    end
    runner.converge(described_recipe)
  end
end

shared_examples 'Installation on RedHat' do
  it 'Include recipe to choose repository' do
    expect(chef_run).to include_recipe('mariadb::_mariadb_repository')
  end
  
end

shared_examples 'Installation from SCL' do
  it 'Include SCL repository recipe' do
    expect(chef_run).to include_recipe('yum-scl::default')
  end
  it 'Don t include MariaDB repository recipe' do
    expect(chef_run).not_to include_recipe('mariadb::repository')
  end
end

shared_examples 'Installation from MariaDB' do
  it 'Don t include SCL repository recipe' do
    expect(chef_run).not_to include_recipe('yum-scl::default')
  end
  it 'Include MariaDB repository recipe' do
    expect(chef_run).to include_recipe('mariadb::repository')
  end
end

at_exit { ChefSpec::Coverage.report! }
