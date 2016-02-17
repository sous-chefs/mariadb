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
      when 'fedora'
        package_provided = true if os_version.to_i >= 19
      end
      package_provided
    end

    # Helper to determine mariadb server service name shipped by native package
    # If no native package available on this platform, return nil
    # @param [String] os_platform Indicate operating system type, e.g. centos
    # @param [String] os_version Indicate operating system version, e.g. 7.0
    def os_service_name(os_platform, os_version)
      return nil unless os_package_provided?(os_platform, os_version)
      service_name = 'mariadb'
      if os_platform == 'fedora' && os_version.to_i >= 19
        service_name = 'mysqld'
      end
      service_name
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

    def db_user_password(user)
      if password_data_bag_exists?(user)
        password_from_data_bag(user)
      else
        password_from_attribute(user)
      end
    end

    def password_data_bag_exists?(user)
      begin
        search(node['mariadb']['data_bag']['name'], 'id:' + user).first.has_key?(user)
      rescue
        Chef::Log.info("Password for #{user} not found in data bag #{node['mariadb']['data_bag']['name']}. Using value in node attribute")
        false
      end
    end

    def password_from_data_bag(user)
      secret_file = Chef::EncryptedDataBagItem.load_secret(node['mariadb']['data_bag']['secret_file'])
      Chef::EncryptedDataBagItem.load(node['mariadb']['data_bag']['name'], user, secret_file)[user]
    end

    def password_from_attribute(user)
      case user
      when 'root'
        return node['mariadb']['server_root_password']
      when 'debian'
        return node['mariadb']['debian']['password']
      when 'wsrep_sst_user'
        return node['mariadb']['galera']['wsrep_sst_password']
      end
    end

  end
end
