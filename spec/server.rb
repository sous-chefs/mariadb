require 'server_spec_helper'

describe 'mariadb::default' do
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
          [nil, '/home/mysql'].each do |data_dir|
            context "MariaDB #{mariadb_version} on #{platform_name} #{supported_version}, repository: #{repo_name}, #{data_dir ? 'datadir: ' + data_dir : ''}" do
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
                                              end,
                                 'mysqld' => { 'datadir' => data_dir } } }
              end
              let(:server_package) { chef_run.package('MariaDB-server') }
              it_behaves_like 'MariaDB server installation'

              case platform_name
              when 'centos'
                it_behaves_like 'Installation on RedHat'
                it_behaves_like 'MariaDB Server on RedHat'
              when 'debian'
                it_behaves_like 'MariaDB Server on Debian'
              end

              case repo_name
              when 'SCL'
                it_behaves_like 'Installation from SCL', %w(server), mariadb_version
              when 'MariaDB'
                case platform_name
                when 'debian'
                  it_behaves_like 'Installation from MariaDB on Debian', %w(server), mariadb_version
                when 'centos'
                  it_behaves_like 'Installation from MariaDB on RedHat', %w(server shared), mariadb_version
                end
              else
                it_behaves_like 'Installation from OS native repository', %w(server), mariadb_version
              end

              if data_dir
                let(:data_directory) { mariadb_mysqld_attr('datadir') }
                it_behaves_like 'MariaDB Server with alternative datadir'
              end
            end
          end
        end
      end
    end
  end
end
