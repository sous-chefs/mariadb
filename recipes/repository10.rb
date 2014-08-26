case node['mariadb']['install']
when 'apt'
  include_recipe "apt::default"

  if node['mariadb']['apt']['use_default_repository']
    apt_repository "mariadb-10.0" do
      uri "http://ftp.igh.cnrs.fr/pub/mariadb/repo/10.0/debian"
      distribution "wheezy"
      components [ "main" ]
      keyserver "keyserver.ubuntu.com"
      key "0xcbcb082a1bb943db"
    end
  end
else
end
