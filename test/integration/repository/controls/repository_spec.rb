# frozen_string_literal: true

version = file('/tmp/mariadb_version').content

if os.debian?
  describe apt("https://mirror.mariadb.org/repo/#{version}/#{os.name}") do
    it { should exist }
    it { should be_enabled }
  end
else
  describe yum.repo("mariadb#{version}") do
    it { should exist }
    it { should be_enabled }
  end
end
