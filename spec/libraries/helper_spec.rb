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
end
