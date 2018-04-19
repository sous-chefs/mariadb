provides :mysql2_gem
resource_name :mysql2_gem

property :compile_time, [true, false], default: false

default_action :install

action :install do
  build_essential 'install_packages'
  cmake_name = if node['platform'] == 'centos' && node['platform_version'].to_i >= 7
                 'cmake3'
               else
                 'cmake'
               end
  package cmake_name do
    action :install
  end
  if Dir.glob('/opt/chef/embedded/lib/ruby/gems/?.?.?/gems/mysql2-?.?.?/lib/mysql2/mysql2.so').empty?

    # First install curl
    if Dir.glob('/opt/chef/embedded/lib/libcurl.*.so').empty?
      remote_file "#{Chef::Config[:file_cache_path]}/curl-#{node['mariadb']['mysql2_gem']['curl_version']}.tar.gz" do
        source node['mariadb']['mysql2_gem']['curl_source_url']
        action :create
      end
      bash 'extract_curl' do
        cwd ::File.dirname('/tmp/')
        code <<-EOH
          cd /tmp
          tar xzf #{Chef::Config[:file_cache_path]}/curl-#{node['mariadb']['mysql2_gem']['curl_version']}.tar.gz
          EOH
      end
      execute 'configure_and_install_curl' do
        command 'cd /tmp/curl-' + node['mariadb']['mysql2_gem']['curl_version'] + ' && ./configure --prefix=/opt/chef/embedded --disable-manual --disable-debug --enable-optimize --disable-ldap --disable-ldaps --disable-rtsp --enable-proxy --disable-dependency-tracking --enable-ipv6 --without-libidn --without-gnutls --without-librtmp --with-ssl=/opt/chef/embedded --with-zlib=/opt/chef/embedded --with-ca-bundle=/opt/chef/embedded/ssl/certs/cacert.pem && make && make install-exec'
      end
    end

    # Then install libmariadb
    if Dir.glob('/opt/chef/embedded/lib/libmariadb*.so').empty?
      remote_file "#{Chef::Config[:file_cache_path]}/mariadb-connector-c-#{node['mariadb']['mysql2_gem']['mariadb_connector_version']}.tar.gz" do
        source node['mariadb']['mysql2_gem']['mariadb_connector_source_url']
        action :create
      end
      bash 'extract_libmariadb' do
        cwd ::File.dirname('/tmp/')
        code <<-EOH
          cd /tmp
          tar xzf #{Chef::Config[:file_cache_path]}/mariadb-connector-c-#{node['mariadb']['mysql2_gem']['mariadb_connector_version']}.tar.gz
          EOH
      end
      execute 'configure_and_install_libmariadb' do
        command 'cd /tmp/mariadb-connector-c-' + node['mariadb']['mysql2_gem']['mariadb_connector_version'] + ' && ' + cmake_name + ' -DCMAKE_INSTALL_PREFIX:PATH=/opt/chef/embedded -DCMAKE_INCLUDE_PATH=/opt/chef/embedded/include/ -DCMAKE_LIBRARY_PATH=/opt/chef/embedded/lib/ . && make all install'
      end
    end

    # Then finish with mysql2 gem
    chef_gem 'mysql2' do
      action :install
      compile_time false
      options '-- --with-mysql-config=/opt/chef/embedded/bin/mariadb_config'
    end
  end
end

action :remove do
  chef_gem 'mysql2' do
    action :remove
  end
end

def after_created
  return unless compile_time
  Array(action).each do |action|
    run_action(action)
  end
end
