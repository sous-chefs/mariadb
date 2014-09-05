case node["platform"]
when "debian", "ubuntu"
  install_method = 'apt'
when "redhat", "centos", "fedora"
  install_method = 'yum'
end

if node['mariadb']['use_default_repository']
  case install_method
  when 'apt'
    include_recipe 'apt::default'
  
    apt_repository "mariadb-#{node['mariadb']['install']['version']}" do
      uri "http://ftp.igh.cnrs.fr/pub/mariadb/repo/#{node['mariadb']['install']['version']}/debian"
      distribution 'wheezy'
      components ['main']
      keyserver 'keyserver.ubuntu.com'
      key '0xcbcb082a1bb943db'
    end
  when 'yum'
    include_recipe 'yum::default'
  
    yum_repository "mariadb-#{node['mariadb']['install']['version']}" do
      baseurl "http://yum.mariadb.org/#{node['mariadb']['install']['version']}/centos6-amd64"
      gpgkey 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
      action :create
    end
  else
  end
end
