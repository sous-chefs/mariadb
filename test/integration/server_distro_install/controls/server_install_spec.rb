# frozen_string_literal: true

describe service('mariadb') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe mysql_session('root', 'gsql').query('SELECT 1') do
  its('output') { should match(/1/) }
  its('exit_status') { should eq(0) }
end
