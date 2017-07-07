require 'chefspec'
require 'chefspec/berkshelf'

def mariadb_conf_attr(name)
  node[described_cookbook]['configuration'][name]
end

def mariadb_mysqld_attr(name)
  node[described_cookbook]['mysqld'][name]
end

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
  config.alias_example_group_to :platform
  config.alias_example_group_to :platform_version
end

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
    {}
  end
  let(:node_automatic_attributes) do
    { memory: { total: '2048kB' },
      'ipaddress' => '1.1.1.1' }
  end
  let(:node_override_attributes) do
    {}
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

shared_examples 'MariaDB package installation' do |package, package_name|
  let(:chef_package) { chef_run.package("MariaDB-#{package}") }
  let(:chef_package_name) { package_name }
  it "Install package MariaDB-#{package} with name '#{package_name}'" do
    expect(chef_run).to install_package("MariaDB-#{package}")
    expect(chef_package.package_name).to eq chef_package_name
  end
end

shared_examples 'Installation from SCL' do |packages, mariadb_version|
  it 'Include recipe to choose repository' do
    expect(chef_run).to include_recipe('mariadb::_mariadb_repository')
  end
  it 'Include SCL repository recipe' do
    expect(chef_run).to include_recipe('yum-scl::default')
  end
  it 'Don t include MariaDB repository recipe' do
    expect(chef_run).not_to include_recipe('mariadb::repository')
  end
  unless packages.nil? || mariadb_version.nil?
    package_pref = case mariadb_version
                   when '5.5'
                     'mariadb55-mariadb'
                   when '10.0'
                     'rh-mariadb100-mariadb'
                   when '10.1'
                     'rh-mariadb101-mariadb'
                   end
    packages.each do |package|
      package_name = package != 'client' ? "#{package_pref}-#{package}" : package_pref
      it_behaves_like 'MariaDB package installation', package, package_name
    end
  end
end

shared_examples 'Installation from MariaDB repository' do
  it 'Don t include SCL repository recipe' do
    expect(chef_run).not_to include_recipe('yum-scl::default')
  end
  it 'Include MariaDB repository recipe' do
    expect(chef_run).to include_recipe('mariadb::repository')
  end
end

shared_examples 'Installation from MariaDB on Debian' do |packages, mariadb_version|
  it_behaves_like 'Installation from MariaDB repository'
  unless packages.nil? || mariadb_version.nil?
    packages.each do |package|
      package_name = package != 'devel' ? "mariadb-#{package}-#{mariadb_version}" : 'libmariadbclient-dev'
      it_behaves_like 'MariaDB package installation', package, package_name
    end
  end
end

shared_examples 'Installation from MariaDB on RedHat' do |packages, mariadb_version|
  it_behaves_like 'Installation from MariaDB repository'
  it 'Include recipe to choose repository' do
    expect(chef_run).to include_recipe('mariadb::_mariadb_repository')
  end
  unless packages.nil? || mariadb_version.nil?
    packages.each do |package|
      package_name = "MariaDB-#{package}"
      it_behaves_like 'MariaDB package installation', package, package_name
    end
  end
end

shared_examples 'Installation from OS native repository' do |packages, mariadb_version|
  it 'Don t include SCL repository recipe' do
    expect(chef_run).not_to include_recipe('yum-scl::default')
  end
  it 'Don t include MariaDB repository recipe' do
    expect(chef_run).not_to include_recipe('mariadb::repository')
  end
  unless packages.nil? || mariadb_version.nil?
    packages.each do |package|
      package_name = package != 'client' ? "mariadb-#{package}" : 'mariadb'
      it_behaves_like 'MariaDB package installation', package, package_name
    end
  end
end

at_exit { ChefSpec::Coverage.report! }
