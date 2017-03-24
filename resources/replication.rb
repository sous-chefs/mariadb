#
# Cookbook Name:: mariadb
# Resource:: replication
#

actions :add, :remove, :start, :stop
default_action :add

# name of the extra conf file, used for .cnf filename
property :connection_name, kind_of: String, name_attribute: true
property :host, kind_of: [String, NilClass], default: 'localhost', desired_state: false
property :port, kind_of: [String, NilClass], default: node['mariadb']['mysqld']['port'].to_s, desired_state: false
property :user, kind_of: [String, NilClass], default: 'root', desired_state: false
property :password, kind_of: [String, NilClass], default: node['mariadb']['server_root_password'], sensitive: true, desired_state: false
property :change_master_while_running, kind_of: [TrueClass, FalseClass], default: false, desired_state: false
property :master_host, kind_of: String
property :master_user, kind_of: String
property :master_password, kind_of: String, sensitive: true
property :master_connect_retry, kind_of: String
property :master_port, kind_of: Integer, default: 3306
property :master_log_pos, kind_of: Integer
property :master_log_file, kind_of: String
property :master_use_gtid, kind_of: String, default: 'No'

action_class do
  include MariaDB::Connection::Helper

  def replication_query(query)
    socket = if node['mariadb']['client']['socket'] && host == 'localhost'
               node['mariadb']['client']['socket']
             end
    connect(host: host, port: port, username: user, password: password, socket: socket) unless connected?(host, user)
    unless server_older_than?('10.0')
      default_master_connection = connection_name == 'default' ? '' : connection_name
      query(host, user, "SET @@default_master_connection='#{default_master_connection}'")
    end
    query(host, user, query)
  end

  def mariadb_version
    socket = if node['mariadb']['client']['socket'] && host == 'localhost'
               node['mariadb']['client']['socket']
             end
    connect(host: host, port: port, username: user, password: password, socket: socket) unless connected?(host, user)
    query(host, user,
          'SELECT VERSION()').each { |row| return row['VERSION()'][/([\d\.]+)-MariaDB.*/, 1] }
  end

  def server_older_than?(version)
    Gem::Version.new(mariadb_version) < Gem::Version.new(version)
  end

  def slave_running?
    # Couldn't make status variable work, returns OFF even though slave is running sometimes
    # replication_query("SHOW STATUS LIKE 'Slave_running'").each { |row| return row['Value'] == 'YES' }
    slave_status = slave_status?
    return false unless slave_status
    slave_status?.each do |row|
      return row['Slave_IO_Running'] == 'Yes' || row['Slave_SQL_Running'] == 'Yes'
    end
    false
  end

  def change_master_to(master_attrs)
    change_query = if server_older_than?('10.0') || connection_name == 'default'
                     'CHANGE MASTER TO '
                   else
                     "CHANGE MASTER '#{connection_name}' TO "
                   end
    master_settings = []
    master_attrs.each_pair do |attribute, value|
      master_settings << "#{attribute}=#{value}"
    end
    replication_query(change_query + master_settings.join(', '))
  end

  def slave_status?
    status_query = if server_older_than?('10.0') || connection_name == 'default'
                     'SHOW SLAVE STATUS'
                   else
                     "SHOW SLAVE '#{connection_name}' STATUS"
                   end
    replication_query(status_query)
  rescue Mysql2::Error => mysql_exception
    nil if mysql_exception.message =~ /There is no master connection.*/
  end

  def start_slave
    if server_older_than?('10.0') || connection_name == 'default'
      replication_query('START SLAVE')
    else
      replication_quesry("START SLAVE'#{connection_name}'")
    end
  end

  def stop_slave
    if server_older_than?('10.0') || connection_name == 'default'
      replication_query('STOP SLAVE')
    else
      replication_quesry("STOP SLAVE'#{connection_name}'")
    end
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
    mysql_server_version = ''
    mysql_connection.query('SELECT VERSION()').each do |row|
      mysql_server_version = row['VERSION()']
    end
    master_connection = if mysql_server_version.to_i < 10 || connection_name == 'default'
                          ''
                        else
                          connection_name
                        end
    status_query = if master_connection.empty?
                     'SHOW SLAVE STATUS'
                   else
                     "SHOW SLAVE '#{master_connection}' STATUS"
                   end
    slave_status = mysql_connection.query(status_query)
    current_value_does_not_exist! if slave_status.count == 0
    slave_status.each do |row|
      master_host row['Master_Host']
      master_port row['Master_Port']
      master_user row['Master_User']
      master_log_file row['Master_Log_File']
      master_log_pos row['Read_Master_Log_Pos']
      master_use_gtid row['Using_Gtid'].nil? ? 'No' : row['Using_Gtid']
    end
    master_info_file = if master_connection.empty?
                         "#{node['mariadb']['mysqld']['datadir']}/master.info"
                       else
                         "#{node['mariadb']['mysqld']['datadir']}/master-#{master_connection}.info"
                       end
    master_password IO.readlines(master_info_file)[5].chomp
  rescue Mysql2::Error => mysql_exception
    current_value_does_not_exist! if mysql_exception.message =~ /There is no master connection.*/
    raise "Mysql connection error: #{mysql_exception.message}"
  ensure
    mysql_connection.close
  end
end

action :add do
  if change_master_while_running || !slave_running?
    converge_if_changed :master_host, :master_port, :master_user, :master_password, :master_use_gtid do
      if master_host.nil? || master_user.nil? || master_password.nil? || master_port.nil?
        raise '[ERROR] When adding a slave, you have to define master_host' \
              ' master_user and master_password and master_port!'
      end
      master_config = { MASTER_HOST: "'#{master_host}'", MASTER_PORT: master_port,
                        MASTER_USER: "'#{master_user}'", MASTER_PASSWORD: "'#{master_password}'" }
      if master_use_gtid.casecmp('no') == 0 || server_older_than?('10.0.2')
        Chef::Log.warn('use_gtid requires MariaDB 10.0 or older. Falling back to bin-log.') unless master_use_gtid.casecmp('no') == 0
        if master_log_name.nil? || master_log_pos.nil?
          raise '[ERROR] When adding a slave without GTID, you have to' \
                'define master_log_file and master_log_pos !'
        end
        master_config[:MASTER_LOG_FILE] = "'#{master_log_file}'"
        master_config[:MASTER_LOG_POS] = master_log_pos
      else
        master_config[:MASTER_USE_GTID] = master_use_gtid
      end
      slave_was_running = slave_running?
      stop_slave if slave_running?
      change_master_to(master_config)
      start_slave if slave_was_running
    end
  end
end

action :remove do
  return if current_value.nil?
  stop_slave if slave_running?
  reset_slave
end

action :start do
  start_slave unless slave_running?
end

action :stop do
  stop_slave if slave_running?
end
