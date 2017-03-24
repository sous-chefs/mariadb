# MariaDB is a module containing mariadb cookbook helpers
module MariaDB
  # Connection is a module containing helpers for mysql connection handling
  module Connection
    # Helper module for mariadb cookbook
    module Helper
      def initialize(new_resource, run_context)
        super
        mysql2_gem 'mysql2' do
          compile_time true
          action :install
        end
        @connection_pool ||= {}
      end

      def connect(host:, port: '3306', username:, password: nil, socket: nil)
        require 'mysql2'
        unless @connection_pool["#{username}@#{host}"]
          conn_options = { username: username,
                           password: password,
                           port: port }.merge!(socket.nil? ? { host: host } : { socket: socket })
          @connection_pool["#{username}@#{host}"] = Mysql2::Client.new(conn_options)
        end
        @connection_pool["#{username}@#{host}"]
      end

      def connected?(host, username)
        !@connection_pool["#{username}@#{host}"].nil?
      end

      def disconnect(host, username)
        require 'mysql2'
        if @connection_pool["#{username}@#{host}"]
          @connection_pool["#{username}@#{host}"].close
        else
          Chef::Log.warn("Close mysql connections: Couldn't find connection #{username}@#{host} in the pool.")
        end
      rescue Mysql2::Error => mysql_exception
        Chef::Log.warn("Close mysql connections: #{mysql_exception.message}.")
      ensure
        @connection_pool.delete_if { |connection_name, _| connection_name == "#{username}@#{host}" }
      end

      def query(host, username, query)
        raise "Connection to mysql #{username}@#{host} is not established. Can't run query." unless connected?(host, username)
        @connection_pool["#{username}@#{host}"].query(query)
      rescue Mysql2::Error => mysql_exception
        raise if mysql_exception.message =~ /There is no master connection.*/
        raise "Mysql query error: #{mysql_exception.message}"
      end
    end
  end
end
