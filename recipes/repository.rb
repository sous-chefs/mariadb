case node['platform']
when 'debian', 'ubuntu'
  install_method = 'apt'
when 'redhat', 'centos', 'fedora', 'scientific', 'amazon'
  install_method = 'yum'
end

if node['mariadb']['use_default_repository']
  case install_method
  when 'apt'
    include_recipe 'apt::default'

    apt_repository "mariadb-#{node['mariadb']['install']['version']}" do
      uri 'http://' + node['mariadb']['apt_repository']['base_url'] + '/' + \
        node['mariadb']['install']['version'] + '/' + node['platform']
      distribution node['lsb']['codename']
      components ['main']
      keyserver 'keyserver.ubuntu.com'
      key 'CBCB082A1BB943DB'
    end
  when 'yum'
    include_recipe 'yum::default'

    target_platform = if node['platform'] == 'redhat' || node['platform'] == 'scientific'
                        "rhel#{node['platform_version'].to_i}"
                      else
                        "#{node['platform']}#{node['platform_version'].to_i}"
                      end
    yum_repository "mariadb-#{node['mariadb']['install']['version']}" do
      description 'MariaDB Official Repository'
      baseurl 'http://yum.mariadb.org/' + \
        node['mariadb']['install']['version'] + "/#{target_platform}-amd64"
      gpgkey 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
      action :create
    end

    case node['platform']
    when 'redhat', 'centos', 'scientific'
      include_recipe 'yum-epel::default'
    end
  end
end
