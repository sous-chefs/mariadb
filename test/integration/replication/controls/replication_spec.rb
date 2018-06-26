control 'mariadb_replication' do
  impact 1.0
  title 'test creation and removal of replication'

  describe service('mysql') do
    it { should be_enabled   }
    it { should be_running   }
  end

  describe port('3306') do
    it { should be_listening }
  end

  %w(1 2 3).each do |index|
    describe command('/usr/bin/mysql -r -B -N -e "SHOW ALL SLAVES STATUS;" -pgsql | cut -f 1 | head -n ' + (index.to_i + 1).to_s + ' | tail -n 1') do
      its(:stdout) { should match 'server' + index }
    end
  end
end
