case node['mariadb']['install']
when 'apt'
  if node['mariadb']['apt']['use_default_repository']
    apt_repository 'mariadb-5.5' do
      uri 'http://ftp.igh.cnrs.fr/pub/mariadb/repo/5.5/debian'
      distribution 'wheezy'
      components ['main']
      keyserver 'keyserver.ubuntu.com'
      key '0xcbcb082a1bb943db'
    end
  end
else
end
