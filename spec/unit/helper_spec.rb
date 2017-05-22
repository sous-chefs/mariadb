require 'spec_helper'

describe MariaDB::Helper do
  describe '#mariadb_service_restart_required?' do
    let(:dummy_class) { Class.new { include MariaDB::Helper } }
    context 'Port is open' do
      let(:dummy_helper) { dummy_class.new }
      before do
        allow(dummy_helper).to receive(:port_open?)
          .with('127.0.0.1', 3306)
          .and_return(true)
      end

      it 'return false' do
        expect(
          dummy_helper.mariadb_service_restart_required?(
            '127.0.0.1',
            3306,
            '/tmp/mysql.sock'
          )
        ).to be false
      end
    end

    context 'Port is closed' do
      let(:dummy_helper) { dummy_class.new }
      before do
        allow(dummy_helper).to receive(:port_open?)
          .with('127.0.0.1', 3306)
          .and_return(false)
      end

      it 'return true' do
        expect(
          dummy_helper.mariadb_service_restart_required?(
            '127.0.0.1',
            3306,
            '/tmp/mysql.sock'
          )
        ).to be true
      end
    end
  end

  describe '#use_os_native_package?' do
    let(:dummy_class) { Class.new { include MariaDB::Helper } }
    let(:dummy_helper) { dummy_class.new }

    context 'os package provided' do
      let(:supported_platforms) do
        Hash['redhat' => %w(7.0 7.1),
             'centos' => %w(7.0),
        ]
      end
      let(:support_mariadb) do
        Array['5.5', '10.0', '10.1']
      end

      it 'os_package_provided to be true' do
        supported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.os_package_provided?(
                platform, version
              )
            ).to be true
          end
        end
      end

      it 'use native package' do
        supported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.use_os_native_package?(
                true, platform, version
              )
            ).to be true
            expect(
              dummy_helper.use_os_native_package?(
                false, platform, version
              )
            ).to be false
          end
        end
      end

      it 'mariadb service name' do
        supported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            support_mariadb.each do |mariadb_version|
              expect(
                dummy_helper.mariadb_service_name(
                  platform, version, mariadb_version, true, false
                )
              ).to eq('mariadb')
            end
          end
        end
      end
    end

    context 'os package not provided' do
      let(:unsupported_platforms) do
        Hash['redhat' => %w(5.5 6.4 6.5),
             'centos' => %w(5.4 6.6),
             'ubuntu' => %w(11.04 12.04 14.04),
             'debian' => %w(7.8)
        ]
      end
      let(:support_mariadb) do
        Array['5.5', '10.0', '10.1']
      end

      it 'os_package_provided to be false' do
        unsupported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.os_package_provided?(
                platform, version
              )
            ).to be false
          end
        end
      end

      it 'mariadb service falls back to default' do
        unsupported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            support_mariadb.each do |mariadb_version|
              expect(
                dummy_helper.mariadb_service_name(
                  platform, version, mariadb_version, true, false
                )
              ).to eq 'mysql'
            end
          end
        end
      end

      it 'cannot use native package' do
        warn_called = false
        allow(Chef::Log).to receive(:warn) { warn_called = true }
        unsupported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            warn_called = false
            expect(
              dummy_helper.use_os_native_package?(
                true, platform, version
              )
            ).to be false
            expect(warn_called).to be true

            warn_called = false
            expect(
              dummy_helper.use_os_native_package?(
                false, platform, version
              )
            ).to be false
            expect(warn_called).to be false
          end
        end
      end
    end
  end

  describe '#use_scl_package?' do
    let(:dummy_class) { Class.new { include MariaDB::Helper } }
    let(:dummy_helper) { dummy_class.new }

    context 'scl package provided' do
      let(:supported_platforms) do
        Hash['centos' => %w(6.8 7.0),
             'scientific' => %w(6.8),
        ]
      end
      let(:support_mariadb) do
        Array['5.5', '10.0', '10.1']
      end

      it 'os_package_provided to be true' do
        supported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.scl_package_provided?(
                platform, version
              )
            ).to be true
          end
        end
      end
      it 'use scl package' do
        supported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.use_scl_package?(
                true, platform, version
              )
            ).to be true
            expect(
              dummy_helper.use_scl_package?(
                false, platform, version
              )
            ).to be false
          end
        end
      end
      it 'mariadb service name' do
        supported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            support_mariadb.each do |mariadb_version|
              expect(
                dummy_helper.mariadb_service_name(
                  platform, version, mariadb_version, false, true
                )
              ).to eq case mariadb_version
                      when '5.5'
                        'mariadb55-mariadb'
                      when '10.0'
                        'rh-mariadb100-mariadb'
                      when '10.1'
                        'rh-mariadb101-mariadb'
                      end
            end
          end
        end
      end
    end

    context 'scl package not provided' do
      let(:unsupported_platforms) do
        Hash['redhat' => %w(5.5 5.6),
             'centos' => %w(5.2 5.7),
        ]
      end
      let(:support_mariadb) do
        Array['5.5', '10.0', '10.1']
      end

      it 'scl_package_provided to be false' do
        unsupported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.scl_package_provided?(
                platform, version
              )
            ).to be false
          end
        end
      end

      it 'mariadb service falls back to default' do
        unsupported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            support_mariadb.each do |mariadb_version|
              expect(
                dummy_helper.mariadb_service_name(
                  platform, version, mariadb_version, false, true
                )
              ).to eq 'mysql'
            end
          end
        end
      end

      it 'cannot use scl package' do
        warn_called = false
        allow(Chef::Log).to receive(:warn) { warn_called = true }
        unsupported_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            warn_called = false
            expect(
              dummy_helper.use_scl_package?(
                true, platform, version
              )
            ).to be false
            expect(warn_called).to be true

            warn_called = false
            expect(
              dummy_helper.use_scl_package?(
                false, platform, version
              )
            ).to be false
            expect(warn_called).to be false
          end
        end
      end
    end
  end
end
