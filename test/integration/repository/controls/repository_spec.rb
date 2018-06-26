# frozen_string_literal: true

case os.family

when 'redhat'

  describe yum.repo('mariadb10.3') do
    it { should exist }
    it { should be_enabled }
  end

when 'debian'

  case os.name

  when 'debian'

    describe apt('http://mariadb.mirrors.ovh.net/MariaDB/repo/10.3/debian') do
      it { should exist }
      it { should be_enabled }
    end

  when 'ubuntu'

    describe apt('http://mariadb.mirrors.ovh.net/MariaDB/repo/10.3/ubuntu') do
      it { should exist }
      it { should be_enabled }
    end

  end
end
