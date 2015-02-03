require 'spec_helper'

describe service('mysql') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port('3306') do
  it { should be_listening }
end

describe command('/usr/bin/mysql -u root -B -N -e "SELECT 1 '\
                  'FROM information_schema.plugins '\
                  'WHERE PLUGIN_NAME = \"SERVER_AUDIT\"'\
                  'AND PLUGIN_STATUS = \"ACTIVE\""') do
  its(:stdout)  { should match(/^1$/) }
end
