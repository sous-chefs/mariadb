require 'spec_helper'
require_relative '../../libraries/helpers.rb'

RSpec.describe MariaDBCookbook::Helpers do
  class DummyClass < Chef::Node
    include MariaDBCookbook::Helpers
  end
  subject { DummyClass.new }

  describe '#data_dir(version)' do
    before do
      allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
    end

    let(:version) { '10.3' }

    context 'with rhel family and MariaDB 10.3' do
      let(:platform_family) { 'rhel' }

      it 'returns the correct path' do
        expect(subject.data_dir(version)).to eq '/var/lib/mysql/'
      end
    end

    context 'with debian family and MariaDB 10.3' do
      let(:platform_family) { 'debian' }

      it 'returns the correct path' do
        expect(subject.data_dir(version)).to eq '/var/lib/mysql/'
      end
    end
  end

  describe '#wsrep_node_address' do
    it 'returns a node address with a port' do
      new_resource = double(database: 'db_foo', wsrep_node_port: '1234')
      ipaddress = '127.0.0.1'

      expect(subject.wsrep_node_address(new_resource).to eq '127.0.0.1:1234')
    end
  end
end
