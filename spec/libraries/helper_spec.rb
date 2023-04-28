require 'spec_helper'
require_relative '../../libraries/helpers'

RSpec.describe MariaDBCookbook::Helpers do
  class DummyClass < Chef::Node
    include MariaDBCookbook::Helpers
  end
  subject { DummyClass.new }

  describe 'helpers' do
    before do
      allow(subject).to receive(:[]).with(:platform_family).and_return(platform_family)
      allow(subject).to receive(:mariadb_version).and_return(Gem::Version.new(mariadb_version))
    end

    context 'with rhel family' do
      let(:platform_family) { 'rhel' }
      let(:mariadb_version) { '10.3' }

      # All common to RHEL
      it 'returns the correct paths' do
        expect(subject.conf_dir).to eq '/etc'
        expect(subject.ext_conf_dir).to eq '/etc/my.cnf.d'
        expect(subject.default_socket).to eq '/var/lib/mysql/mysql.sock'
        expect(subject.default_pid_file).to eq '/var/run/mariadb/mariadb.pid'
      end

      it 'returns the correct libgalera path' do
        expect(subject.default_libgalera_smm_path).to eq '/usr/lib64/galera/libgalera_smm.so'
      end

      it 'returns the correct encoding and collation' do
        expect(subject.default_encoding).to eq 'utf8'
        expect(subject.default_collation).to eq 'utf8_general_ci'
      end

      # MariaDB version differences
      context 'with mariadb 10.11' do
        let(:mariadb_version) { '10.11' }

        it 'returns the correct libgalera path' do
          expect(subject.default_libgalera_smm_path).to eq '/usr/lib64/galera-4/libgalera_smm.so'
        end

        it 'returns the correct encoding and collation' do
          expect(subject.default_encoding).to eq 'utf8mb3'
          expect(subject.default_collation).to eq 'utf8mb3_general_ci'
        end
      end
    end

    context 'with debian family' do
      let(:platform_family) { 'debian' }
      let(:mariadb_version) { '10.3' }

      it 'returns the correct paths' do
        expect(subject.conf_dir).to eq '/etc/mysql'
        expect(subject.ext_conf_dir).to eq '/etc/mysql/conf.d'
        expect(subject.default_socket).to eq '/var/run/mysqld/mysqld.sock'
        expect(subject.default_pid_file).to eq '/var/run/mysqld/mysqld.pid'
        expect(subject.default_libgalera_smm_path).to eq '/usr/lib/galera/libgalera_smm.so'
      end
    end
  end
end
