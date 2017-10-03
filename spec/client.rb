require 'spec_helper'

describe 'mariadb::client' do
  before do
    allow(TCPSocket).to receive(:new).and_return(tcpsocket_obj)
  end
  test_matrix = { '5.5' => { 'OS' => { 'centos' => %w(7.0) },
                             'SCL' => { 'centos' => %w(6.5 7.0) },
                             'MariaDB' => { 'centos' => %w(6.5 7.0), 'debian' => %w(7.11) } },
                  '10.0' => { 'SCL' => { 'centos' => %w(6.5 7.0) },
                              'MariaDB' => { 'centos' => %w(6.5 7.0), 'debian' => %w(7.11) } },
                  '10.1' => { 'SCL' => { 'centos' => %w(6.5 7.0) },
                              'MariaDB' => { 'centos' => %w(6.5 7.0), 'debian' => %w(7.11) } } }
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
            let(:node_override_attributes) do
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
            case repo_name
            when 'SCL'
              it_behaves_like 'Installation from SCL', %w(client devel), mariadb_version
              if supported_version.to_i < 7
                it 'Remove mysql-libs package' do
                  expect(chef_run).to remove_package('mysql-libs')
                end
              end
            when 'MariaDB'
              case platform_name
              when 'debian'
                it_behaves_like 'Installation from MariaDB on Debian', %w(client devel), mariadb_version
              when 'centos'
                it_behaves_like 'Installation from MariaDB on RedHat', %w(client devel), mariadb_version
                if supported_version.to_i < 7
                  it 'Remove mysql-libs package' do
                    expect(chef_run).to remove_package('mysql-libs')
                  end
                end
              end
            else
              it_behaves_like 'Installation from OS native repository', %w(client devel), mariadb_version
            end
          end
        end
      end
    end
  end
end
