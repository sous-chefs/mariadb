require 'spec_helper'

describe service('mysql') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port('3306') do
  it { should be_listening }
end

%w(1 2 3).each do |i|
  describe command('/usr/bin/mysql -r -B -N -e "SHOW ALL SLAVES STATUS;"' \
                   ' | cut -f 1 | head -n ' + i + ' | tail -n 1') do
    its(:stdout) { should match 'server' + i }
  end
end
