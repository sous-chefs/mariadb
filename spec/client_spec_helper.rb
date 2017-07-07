require 'spec_helper'

shared_examples 'MariaDB client installation' do
  it 'Install MariaDB Client Package' do
    expect(chef_run).to install_package('MariaDB-client')
  end
end

shared_examples 'MariaDB devel installation skipped' do
  it 'Don t include devel recipe' do
    expect(chef_run).to_not include_recipe('mariadb::devel')
  end
  it 'Don t install MariaDB Client Devel Package' do
    expect(chef_run).to_not install_package('MariaDB-devel')
  end
end

shared_examples 'MariaDB devel installation' do
  it 'Include devel recipe' do
    expect(chef_run).to include_recipe('mariadb::devel')
  end
  it 'Install MariaDB Client Devel Package' do
    expect(chef_run).to install_package('MariaDB-devel')
  end
end

shared_examples 'MariaDB client on RedHat' do
  it 'Include RH specific recipe' do
    expect(chef_run).to include_recipe('mariadb::_redhat_client')
  end
end
