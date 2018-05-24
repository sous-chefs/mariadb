# MariaDB is a module containing mariadb cookbook helper
module MariaDB
  # Helper module for mariadb cookbook
  module Helper
    require 'socket'
    require 'timeout'

    def do_port_connect(ip, port)
      s = TCPSocket.new(ip, port)
      s.close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      false
    end

    def port_open?(ip, port)
      begin
        Timeout.timeout(5) do
          return do_port_connect(ip, port)
        end
      rescue Timeout::Error
        false
      end
      false
    end

    # Trying to determine if we need to restart the mysql service
    def mariadb_service_restart_required?(ip, port, _socket)
      restart = false
      restart = true unless port_open?(ip, port)
      restart
    end

    # Helper to determine if running operating system shipped a package for
    # mariadb server & client. No galera shipped in any os yet.
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] os_version Indicate operating system version, e.g. 7.0
    def os_package_provided?(os_platform, os_version)
      package_provided = false
      case os_platform
      when 'centos', 'redhat'
        package_provided = true if os_version.to_i == 7
      when 'ubuntu'
        package_provided = true if os_version.to_i >= 16
      when 'debian'
        package_provided = true if os_version.to_i >= 9
      end
      package_provided
    end

    # Helper to determine if running operating system's scl provides a package
    # mariadb server & client. No galera shipped in any os yet.
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] os_version Indicate operating system version, e.g. 7.0
    def scl_package_provided?(os_platform, os_version)
      package_provided = false
      case os_platform
      when 'centos', 'redhat', 'scientific'
        package_provided = true if os_version.to_i >= 6
      end
      package_provided
    end

    # Helper to determine whether to use os native package
    # @param [Boolean] prefer_os Indicate whether to prefer os native package
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] os_version Indicate operating system version, e.g. 7.0
    def use_os_native_package?(prefer_os, os_platform, os_version)
      return false unless prefer_os
      if os_package_provided?(os_platform, os_version)
        true
      else
        Chef::Log.warn 'prefer_os_package detected, but no native mariadb'\
          " package available on #{os_platform}-#{os_version}."\
          ' Fall back to use community package.'
        false
      end
    end

    # Helper to determine whether to use scl package
    # @param [Boolean] prefer_scl Indicate whether to prefer package from SCL
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] os_version Indicate operating system version, e.g. 7.0
    def use_scl_package?(prefer_scl, os_platform, os_version)
      return false unless prefer_scl
      if scl_package_provided?(os_platform, os_version)
        true
      else
        Chef::Log.warn 'prefer_scl_package detected, but no scl mariadb'\
          " package available on #{os_platform}-#{os_version}."\
          ' Fall back to use community package.'
        false
      end
    end

    # Helper to determine whether requested version is available from scl repo
    # @param [String] version Indicate requested version of mariadb
    def scl_version_available?(mariadb_version)
      if ['5.5', '10.0', '10.1'].include?(mariadb_version)
        true
      else
        Chef::Log.warn "Version #{mariadb_version} was requested, but"\
          ' but not available from scl. Fall back to use community package.'
        false
      end
    end

    # Helper to determine scl package name's prefix
    # @param [String] version Indicate requested version of mariadb
    def scl_collection_name(mariadb_version)
      case mariadb_version
      when '5.5'
        'mariadb55'
      when '10.0'
        'rh-mariadb100'
      when '10.1'
        'rh-mariadb101'
      end
    end

    # Helper to determine scl packages names
    # @param [String] version Indicate requested version of mariadb
    # @param [String] package Indicate mariadb component name
    def scl_package_name(version, package)
      "#{scl_collection_name(version)}-#{package}"
    end

    # Helper to determine the command required to execute mariadb utils
    # @param [Boolean] prefer_scl Indicate whether to prefer package from SCL
    # @param [String] mariadb_version Indicate requested version of mariadb
    # @param [String] cmd Indicate what command has to be executed
    def mysqlbin_cmd(prefer_scl, mariadb_version, cmd)
      if prefer_scl && scl_version_available?(mariadb_version)
        "scl enable #{scl_collection_name(mariadb_version)} -- #{cmd}"
      else
        "/usr/bin/#{cmd}"
      end
    end

    # Helper to determine names of mariadb packages provided by OS
    # @param [String] os_platform Indicate operating system type, e.g. centos
    def native_packages_names(os_platform)
      case os_platform
      when 'redhat', 'centos', 'scientific'
        { 'devel' => 'mariadb-devel',
          'client' => 'mariadb',
          'server' => 'mariadb-server' }
      when 'suse'
        { 'devel' => 'libmariadbclient-devel',
          'client' => 'mariadb-community-server-client',
          'server' => 'mariadb-community-server' }
      when 'debian'
        { 'devel' => 'libmariadbclient-dev',
          'client' => 'mariadb-client',
          'server' => 'mariadb-server' }
      when 'ubuntu'
        if node['platform_version'].to_i >= 16
          { 'devel' => 'libmariadb-client-lgpl-dev',
            'client' => 'mariadb-client',
            'server' => 'mariadb-server' }
        else
          { 'devel' => 'libmariadbclient-dev',
            'client' => 'mariadb-client',
            'server' => 'mariadb-server' }
        end
      end
    end

    # Helper to determine names of mariadb packages provided by SCL
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] mariadb_version Indicate requested version of mariadb
    def scl_packages_names(os_platform, mariadb_version)
      packages = {}
      native_packages_names(os_platform).each_pair do |package_type, package_name|
        packages[package_type] = scl_package_name(mariadb_version, package_name)
      end
      packages
    end

    # Helper to determine names of mariadb packages provided by MariaDB
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] version Indicate requested version of mariadb
    def mariadb_packages_names(os_platform, version)
      if %w(debian ubuntu).include?(os_platform)
        if version.to_f >= 10.2
          { 'devel' => 'libmariadb-dev',
            'client' => "mariadb-client-#{version}",
            'server' => "mariadb-server-#{version}" }
        else
          { 'devel' => 'libmariadbclient-dev',
            'client' => "mariadb-client-#{version}",
            'server' => "mariadb-server-#{version}" }
        end
      else
        { 'devel' => 'MariaDB-devel',
          'client' => 'MariaDB-client',
          'server' => 'MariaDB-server' }
      end
    end

    # Helper to determine names of packages to be used for chosen mariadb version
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] os_version Indicate operating system version
    # @param [String] mariadb_version Indicate requested version of mariadb
    # @param [Boolean] prefer_os Indicate whether to prefer os native package
    # @param [Boolean] prefer_scl Indicate whether to prefer package from SCL
    def packages_names_to_install(os_platform, os_version, mariadb_version, prefer_os, prefer_scl)
      if use_os_native_package?(prefer_os, os_platform, os_version)
        native_packages_names(os_platform)
      elsif use_scl_package?(prefer_scl, os_platform, os_version)
        scl_packages_names(os_platform, mariadb_version)
      else
        mariadb_packages_names(os_platform, mariadb_version)
      end
    end

    # Helper to determine service name for given OS and chosen installation method
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] os_version Indicate operating system version
    # @param [String] mariadb_version Indicate requested version of mariadb
    # @param [Boolean] prefer_os Indicate whether to prefer os native package
    # @param [Boolean] prefer_scl Indicate whether to prefer package from SCL
    def mariadb_service_name(os_platform, os_version, mariadb_version, prefer_os, prefer_scl)
      if use_os_native_package?(prefer_os, os_platform, os_version)
        case os_platform
        when 'redhat', 'centos', 'scientific', 'debian', 'ubuntu'
          'mariadb'
        end
      elsif use_scl_package?(prefer_scl, os_platform, os_version)
        "#{scl_collection_name(mariadb_version)}-mariadb"
      else
        'mysql'
      end
    end
  end
end
