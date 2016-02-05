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
      let(:support_platforms) do
        Hash['redhat' => %w(7.0 7.1),
             'centos' => %w(7.0),
             'fedora' => %w(19 20 21)
        ]
      end

      it 'os_package_provided to be true' do
        support_platforms.each do |platform, ver_list|
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
        support_platforms.each do |platform, ver_list|
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

      it 'native os service name' do
        support_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            if platform == 'fedora' && version >= '19'
              expect(
                dummy_helper.os_service_name(
                  platform, version
                )
              ).to eq 'mysqld'
            else
              expect(
                dummy_helper.os_service_name(
                  platform, version
                )
              ).to eq 'mariadb'
            end
          end
        end
      end
    end

    context 'os package not provided' do
      let(:unsupport_platforms) do
        Hash['redhat' => %w(5.5 6.4 6.5),
             'centos' => %w(5.4 6.6),
             'fedora' => %w(17 18),
             'ubuntu' => %w(11.04 12.04 14.04),
             'debian' => %w(7.8)
        ]
      end

      it 'os_package_provided to be false' do
        unsupport_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.os_package_provided?(
                platform, version
              )
            ).to be false
          end
        end
      end

      it 'cannot use native package' do
        warn_called = false
        allow(Chef::Log).to receive(:warn) { warn_called = true }
        unsupport_platforms.each do |platform, ver_list|
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

      it 'no native os service name' do
        unsupport_platforms.each do |platform, ver_list|
          ver_list.each do |version|
            expect(
              dummy_helper.os_service_name(
                platform, version
              )
            ).to eq nil
          end
        end
      end
    end
  end
  describe '#dbuser_pass' do
    let(:dummy_class) { Class.new { include MariaDB::Helper } }
    context 'password is attribute' do
      let(:dummy_helper) { dummy_class.new }
      let(:node) {
        {
          'mariadb' => {
            'server_root_password' => 'change_me'
          }
        }
      }
      before do
        allow(dummy_helper).to receive(:node).and_return(node)
        allow(dummy_helper).to receive(:pass_data_bag_exists?).with('root').and_return false
      end
      it 'returns node attributes for password' do
        expect(dummy_helper.dbuser_pass('root')).to eql('change_me')
      end
    end
    context 'password is in databag' do
      let(:dummy_class) { Class.new { include MariaDB::Helper } }
      let(:dummy_helper) { dummy_class.new }
      let(:node) {
        {
          'mariadb' => {
            'data_bag' => {
              'name' => 'mariadb',
              'secret_file' => '/etc/chef/encrypted_data_bag_secret'
            }
          }
        }
      }
      before do
        allow(dummy_helper).to receive(:node).and_return(node)
        allow(dummy_helper).to receive(:pass_data_bag_exists?).with('root').and_return true
        allow(Chef::EncryptedDataBagItem).to receive(:load_secret).with('/etc/chef/encrypted_data_bag_secret').and_return('secret_key')
      end
      it 'returns password from data bag' do
        allow(Chef::EncryptedDataBagItem).to receive(:load).with('mariadb', 'root', 'secret_key').and_return({'password' => 'secret_password'})
        expect(dummy_helper.pass_from_data_bag('root')).to eql('secret_password')
      end
    end
  end
  describe '#pass_data_bag_exists?' do
    let(:dummy_class) { Class.new { include MariaDB::Helper } }
    let(:dummy_helper) { dummy_class.new }
    let(:node) {
      {
        'mariadb' => {
          'data_bag' => {
            'name' => 'mariadb',
            'secret_file' => '/etc/chef/encrypted_data_bag_secret'
          }
        }
      }
    }
    before do
      allow(dummy_helper).to receive(:node).and_return(node)
    end
    it 'finds requested data bag' do
      allow(dummy_helper).to receive(:search).with('mariadb', 'id:root').and_return([{'password' => 'encrypted_value'},{'password' => 'someotherpass'}])
      expect(dummy_helper.pass_data_bag_exists?('root')).to be true
    end
    it 'does not find requested data bag' do
      allow(dummy_helper).to receive(:search).with('mariadb', 'id:root').and_return([{'dummy' => 'dumdum'}])
      expect(dummy_helper.pass_data_bag_exists?('root')).to be false
    end
  end
  describe '#pass_from_attribute' do
    let(:dummy_class) { Class.new { include MariaDB::Helper } }
    let(:dummy_helper) { dummy_class.new }
    let(:node) {
      {
        'mariadb' => {
          'server_root_password' => 'change_me'
        }
      }
    }
    before do
      allow(dummy_helper).to receive(:node).and_return(node)
    end
    it 'returns node attributes for password' do
      expect(dummy_helper.pass_from_attribute('root')).to eql('change_me')
    end
  end
  describe '#pass_from_data_bag' do
    let(:dummy_class) { Class.new { include MariaDB::Helper } }
    let(:dummy_helper) { dummy_class.new }
    let(:node) {
      {
        'mariadb' => {
          'data_bag' => {
            'name' => 'mariadb',
            'secret_file' => '/etc/chef/encrypted_data_bag_secret'
          }
        }
      }
    }
    before do
      allow(dummy_helper).to receive(:node).and_return(node)
      allow(Chef::EncryptedDataBagItem).to receive(:load_secret).with('/etc/chef/encrypted_data_bag_secret').and_return('secret_key')
    end
    it 'returns password from data bag' do
      allow(Chef::EncryptedDataBagItem).to receive(:load).with('mariadb', 'root', 'secret_key').and_return({'password' => 'secret_password'})
      expect(dummy_helper.pass_from_data_bag('root')).to eql('secret_password')
    end
  end
end
