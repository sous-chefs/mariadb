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
        expect(dummy_helper.mariadb_service_restart_required?(
          '127.0.0.1',
          3306,
          '/tmp/mysql.sock'
        )).to be false
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
        expect(dummy_helper.mariadb_service_restart_required?(
          '127.0.0.1',
          3306,
          '/tmp/mysql.sock'
        )).to be true
      end
    end
  end
end
