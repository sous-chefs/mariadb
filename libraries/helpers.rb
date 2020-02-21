#
# Cookbook:: mariadb
# Library:: helpers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module MariaDBCookbook
  module Helpers
    include Chef::Mixin::ShellOut

    require 'securerandom'

    #######
    # Function to execute an SQL statement
    #   Input:
    #     query : Query could be a single String or an Array of String.
    #     database : a string containing the name of the database to query in, nil if no database choosen
    #     ctrl : a Hash which could contain:
    #        - user : String or nil
    #        - password : String or nil
    #        - host : String or nil
    #        - port : String or Integer or nil
    #        - socket : String or nil
    #   Output: A String with cmd to execute the query (but do not execute it!)
    #
    def sql_command_string(query, database, ctrl, grep_for = nil)
      raw_query = query.is_a?(String) ? query : query.join(";\n")
      Chef::Log.debug("Control Hash: [#{ctrl.to_json}]\n")
      cmd = "/usr/bin/mysql -B -e \"#{raw_query}\""
      cmd << " --user=#{ctrl[:user]}" if ctrl && ctrl.key?(:user) && !ctrl[:user].nil?
      cmd << " -p#{ctrl[:password]}"  if ctrl && ctrl.key?(:password) && !ctrl[:password].nil?
      cmd << " -h #{ctrl[:host]}"     if ctrl && ctrl.key?(:host) && !ctrl[:host].nil? && ctrl[:host] != 'localhost'
      cmd << " -P #{ctrl[:port]}"     if ctrl && ctrl.key?(:port) && !ctrl[:port].nil? && ctrl[:host] != 'localhost'
      cmd << " -S #{default_socket}"   if ctrl && ctrl.key?(:host) && !ctrl[:host].nil? && ctrl[:host] == 'localhost'
      cmd << " #{database}"            unless database.nil?
      cmd << " | grep #{grep_for}"     if grep_for
      Chef::Log.debug("Executing this command: [#{cmd}]\n")
      cmd
    end

    #######
    # Function to execute an SQL statement in the default database.
    #   Input: Query could be a single String or an Array of String.
    #   Output: A String with <TAB>-separated columns and \n-separated rows.
    # This is easiest for 1-field (1-row, 1-col) results, otherwise
    # it will be complex to parse the results.
    def execute_sql(query, db_name, ctrl)
      cmd = shell_out(sql_command_string(query, db_name, ctrl),
                      user: 'root')
      if cmd.exitstatus != 0
        Chef::Log.fatal("mysql failed executing this SQL statement:\n#{query}")
        Chef::Log.fatal(cmd.stderr)
        raise 'SQL ERROR'
      end
      cmd.stdout
    end

    def parse_one_row(row, titles)
      return_hash = {}
      index = 0
      row.split("\t").each do |column|
        return_hash[titles[index]] = column
        index += 1
      end
      return_hash
    end

    def parse_mysql_batch_result(mysql_batch_result)
      results = mysql_batch_result.split("\n")
      titles = []
      index = 0
      return_array = []
      results.each do |row|
        if index == 0
          titles = row.split("\t")
        else
          return_array[index - 1] = parse_one_row(row, titles)
        end
        index += 1
      end
      return_array
    end

    #    def database_exists?(new_resource)
    #      sql = %(SELECT datname from pg_database WHERE datname='#{new_resource.database}')
    #
    #      exists = %(psql -c "#{sql}")
    #      exists << " -U #{new_resource.user}" if new_resource.user
    #      exists << " --host #{new_resource.host}" if new_resource.host
    #      exists << " --port #{new_resource.port}" if new_resource.port
    #      exists << " | grep #{new_resource.database}"
    #
    #      cmd = shell_out(exists, user: 'mariadb')
    #      cmd.run_command
    #      cmd.exitstatus == 0
    #    end
    #
    #    def user_exists?(new_resource)
    #      exists = %(psql -c "SELECT rolname FROM pg_roles WHERE rolname='#{new_resource.user}'" | grep '#{new_resource.user}')
    #
    #      cmd = Mixlib::ShellOut.new(exists, user: 'postgres')
    #      cmd.run_command
    #      cmd.exitstatus == 0
    #    end
    #
    #    def role_sql(new_resource)
    #      sql = %(\\\"#{new_resource.user}\\\" WITH )
    #
    #      %w(superuser createdb createrole inherit replication login).each do |perm|
    #        sql << "#{'NO' unless new_resource.send(perm)}#{perm.upcase} "
    #      end
    #
    #      sql << if new_resource.encrypted_password
    #               "ENCRYPTED PASSWORD '#{new_resource.encrypted_password}'"
    #             elsif new_resource.password
    #               "PASSWORD '#{new_resource.password}'"
    #             else
    #               ''
    #             end
    #
    #      sql << if new_resource.valid_until
    #               " VALID UNTIL '#{new_resource.valid_until}'"
    #             else
    #               ''
    #             end
    #    end
    #
    #    def extension_installed?
    #      query = "SELECT 'installed' FROM pg_extension WHERE extname = '#{new_resource.extension}';"
    #      !(execute_sql(query, new_resource.database) =~ /^installed$/).nil?
    #    end

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

    def data_dir(_version = node.run_state['mariadb']['version'])
      '/var/lib/mysql'
    end

    def conf_dir(_version = node.run_state['mariadb']['version'])
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        '/etc'
      when 'debian'
        '/etc/mysql'
      end
    end

    def ext_conf_dir(_version = node.run_state['mariadb']['version'])
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        "#{conf_dir}/my.cnf.d"
      when 'debian'
        "#{conf_dir}/conf.d"
      end
    end

    # determine the platform specific service name
    def platform_service_name(_version = node.run_state['mariadb']['version'])
      'mysql'
    end

    def restart_mariadb_service
      # Using this to generate a service resource to control
      service 'mariadb' do
        service_name platform_service_name
        supports restart: true, status: true, reload: true
        action :restart
      end
    end

    def slave?
      ::File.exist? "#{data_dir}/recovery.conf"
    end

    def initialized?
      return true if ::File.exist?("#{conf_dir}/my.cnf")
      false
    end

    def secure_random
      r = SecureRandom.hex
      Chef::Log.debug "Generated password: #{r}"
      r
    end

    def mariadbbackup_pkg_name
      if platform_family?('rhel', 'fedora', 'amazon')
        'MariaDB-backup'
      else
        new_resource.version == '10.3' ? 'mariadb-backup' : "mariadb-backup-#{new_resource.version}"
      end
    end

    # determine the platform specific server package name
    def server_pkg_name
      platform_family?('debian') ? "mariadb-server-#{new_resource.version}" : 'MariaDB-server'
    end

    # given the base URL build the complete URL string for a yum repo
    def yum_repo_url(base_url)
      "#{base_url}/#{new_resource.version}/#{yum_repo_platform_string}"
    end

    # build the platform string that makes up the final component of the yum repo URL
    def yum_repo_platform_string
      release = yum_releasever
      "#{node['platform']}#{release}-#{node['kernel']['machine'] == 'x86_64' ? 'amd64' : '$basearch'}"
    end

    # on amazon use the RHEL 6 packages. Otherwise use the releasever yum variable
    def yum_releasever
      platform?('amazon') ? '6' : '$releasever'
    end

    def default_socket
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        '/var/lib/mysql/mysql.sock'
      when 'debian'
        '/var/run/mysqld/mysqld.sock'
      end
    end

    def default_pid_file
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        nil
      when 'debian'
        '/var/run/mysqld/mysqld.pid'
      end
    end
  end
end
