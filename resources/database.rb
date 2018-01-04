#
# Cookbook Name:: mariadb
# Resource:: database
#

default_action :create

property :database_name, kind_of: String, name_attribute: true
property :host, kind_of: [String, NilClass], default: 'localhost', desired_state: false
property :port, kind_of: [String, NilClass], default: node['mariadb']['mysqld']['port'].to_s, desired_state: false
property :user, kind_of: [String, NilClass], default: 'root', desired_state: false
property :password, kind_of: [String, NilClass], default: node['mariadb']['server_root_password'], sensitive: true, desired_state: false
property :encoding, kind_of: String, default: 'utf8'
property :collation, kind_of: String, default: 'utf8_general_ci'
property :sql, kind_of: [String, Proc]

action_class do
  include MariaDB::Connection::Helper

  def run_query(query)
    socket = if node['mariadb']['client']['socket'] && new_resource.host == 'localhost'
               node['mariadb']['client']['socket']
             end
    connect(host: new_resource.host, port: new_resource.port, username: new_resource.user, password: new_resource.password, socket: socket) unless connected?(new_resource.host, new_resource.user)
    raw_query = query.is_a?(Proc) ? query.call : query
    Chef::Log.info("#{new_resource.name}: Performing query [#{raw_query}]")
    query(new_resource.host, new_resource.user, raw_query)
  end
end

load_current_value do
  require 'mysql2'
  socket = if node['mariadb']['client']['socket'] && host == 'localhost'
             node['mariadb']['client']['socket']
           end
  conn_options = { username: user, password: password,
                   port: port }.merge!(socket.nil? ? { host: host } : { socket: socket })
  begin
    mysql_connection = Mysql2::Client.new(conn_options)
    results = mysql_connection.query("SHOW DATABASES LIKE '#{database_name}'")
    current_value_does_not_exist! if results.count == 0

    results = mysql_connection.query("SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '#{database_name}'")
    results.each do |row|
      encoding row['DEFAULT_CHARACTER_SET_NAME']
      collation row['DEFAULT_COLLATION_NAME']
    end
  ensure
    mysql_connection.close
  end
end

action :create do
  if current_resource.nil?
    converge_by "Creating database '#{new_resource.database_name}'" do
      create_sql = "CREATE DATABASE IF NOT EXISTS `#{new_resource.database_name}`"
      create_sql += " CHARACTER SET = #{new_resource.encoding}" if new_resource.encoding
      create_sql += " COLLATE = #{new_resource.collation}" if new_resource.collation
      run_query create_sql
    end
  else
    converge_if_changed :encoding do
      run_query "ALTER SCHEMA '#{new_resource.database_name}' CHARACTER SET = #{encoding}"
    end
    converge_if_changed :collation do
      run_query "ALTER SCHEMA '#{new_resource.database_name}' COLLATE = #{collation}"
    end
  end
end

action :drop do
  return if current_resource.nil?
  converge_by "Dropping database '#{new_resource.database_name}'" do
    run_query "DROP DATABASE IF EXISTS `#{new_resource.database_name}`"
  end
end

action :query do
  run_query new_resource.sql
end
