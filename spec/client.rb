require 'client_spec_helper'

describe 'mariadb::client' do
  before do
    allow(TCPSocket).to receive(:new).and_return(tcpsocket_obj)
  end
  test_matrix = { '5.5' => { 'OS' => { 'centos' => %w(7.0) },
                             'SCL' => { 'centos' => %w(6.5 7.0) },
                             'MariaDB' => { 'centos' => %w(6.5 7.0), 'debian' => %w(7.4) } },
                  '10.0' => { 'SCL' => { 'centos' => %w(6.5 7.0) },
                              'MariaDB' => { 'centos' => %w(6.5 7.0), 'debian' => %w(7.4) } },
                  '10.1' => { 'SCL' => { 'centos' => %w(6.5 7.0) },
                              'MariaDB' => { 'centos' => %w(6.5 7.0), 'debian' => %w(7.4) } } }
  test_matrix.each_pair do |mariadb_version, supported_repos|
    supported_repos.each_pair do |repo_name, supported_platforms|
      supported_platforms.each_pair do |platform_name, supported_versions|
        supported_versions.each do |supported_version|
          context "MariaDB #{mariadb_version} on #{platform_name} #{supported_version}, repository: #{repo_name}" do
            include_context('MariaDB installation')
            let(:node_attributes) do
              { platform: platform_name,
                version: supported_version, 
                step_into: ['mariadb_configuration'] } 
            end
            let (:node_override_attributes) do
              { 'mariadb' => { 'install' => case repo_name
                                            when 'SCL'
                                              { 'version' => mariadb_version,
                                              'prefer_os_package' => false,
                                              'prefer_scl_package' => true }
                                            when 'OS'
                                              { 'version' => mariadb_version,
                                              'prefer_os_package' => true,
                                              'prefer_scl_package' => false }
                                            else
                                              { 'version' => mariadb_version,
                                              'prefer_os_package' => false,
                                              'prefer_scl_package' => false }
                                            end } }
            end
            let(:client_package) { chef_run.package('MariaDB-client') }
            it_behaves_like 'MariaDB client installation'
            it_behaves_like 'MariaDB devel installation'
            case platform_name
            when 'centos'
              it_behaves_like 'Installation on RedHat'
              it_behaves_like 'MariaDB client on RedHat'
            #when 'debian'
            #  it_behaves_like 'MariaDB client on Debian'
            end
            case repo_name
            when 'SCL'
              package_name = case mariadb_version
                             when '5.5'
                               'mariadb55-mariadb'
                             when '10.0'
                               'rh-mariadb100-mariadb'
                             when '10.1'
                               'rh-mariadb101-mariadb'
                             end
              it_behaves_like 'Installation from SCL'
              it 'Remove mysql-libs package' do
                expect(chef_run).to remove_package('mysql-libs')
              end
            when 'MariaDB'
              it_behaves_like 'Installation from MariaDB'
              package_name = platform_name == 'debian' ? "mariadb-client-#{mariadb_version}" : 'MariaDB-client'
            else
              package_name = 'mariadb'
              it 'Remove mysql-libs package' do
                expect(chef_run).not_to remove_package('mysql-libs')
              end
            end
            let(:client_package_name) { package_name }
            it "Installs package #{package_name}" do
              expect(client_package.package_name).to eq client_package_name
            end
          end
        end
      end
    end
  end
end
