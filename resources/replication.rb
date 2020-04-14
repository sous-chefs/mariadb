#
# Cookbook:: mariadb
# Resource:: replication
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

include MariaDBCookbook::Helpers

property :connection_name,             String,         name_property: true
property :version,                     String,         default: '10.3'
property :host,                        [String, nil],  default: 'localhost', desired_state: false
property :port,                        [Integer, nil], default: 3306,        desired_state: false
property :user,                        [String, nil],  default: 'root',      desired_state: false
property :password,                    [String, nil], sensitive: true, desired_state: false
property :change_master_while_running, [true, false],  default: false, desired_state: false
property :master_password,             String,         sensitive: true
property :master_port,                 Integer,        default: 3306
property :master_use_gtid,             String,         default: 'No'
property :master_host,                 String
property :master_user,                 String
property :master_connect_retry,        String
property :master_log_pos,              Integer
property :master_log_file,             String

action :add do
  if new_resource.change_master_while_running || !slave_running?
    converge_if_changed :master_host, :master_port, :master_user, :master_password, :master_use_gtid do
      if new_resource.master_host.nil? || new_resource.master_user.nil? || new_resource.master_password.nil? || new_resource.master_port.nil?
        raise '[ERROR] When adding a slave, you have to define master_host' \
              ' master_user and master_password and master_port!'
      end
      master_config = { MASTER_HOST: "'#{new_resource.master_host}'", MASTER_PORT: new_resource.master_port,
                        MASTER_USER: "'#{new_resource.master_user}'", MASTER_PASSWORD: "'#{new_resource.master_password}'" }
      if new_resource.master_use_gtid.casecmp('no') == 0 || server_older_than?('10.0.2')
        Chef::Log.warn('use_gtid requires MariaDB 10.0 or older. Falling back to bin-log.') unless new_resource.master_use_gtid.casecmp('no') == 0
        if new_resource.master_log_name.nil? || new_resource.master_log_pos.nil?
          raise '[ERROR] When adding a slave without GTID, you have to' \
                'define master_log_file and master_log_pos !'
        end
        master_config[:MASTER_LOG_FILE] = "'#{new_resource.master_log_file}'"
        master_config[:MASTER_LOG_POS] = new_resource.master_log_pos
      else
        master_config[:MASTER_USE_GTID] = new_resource.master_use_gtid
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

load_current_value do
  conn_options = { user: user, password: password, host: host, port: port, socket: default_socket }
  master_connection = if version.to_i < 10 || connection_name == 'default'
                        ''
                      else
                        connection_name
                      end
  status_query = if master_connection.empty?
                   'SHOW SLAVE STATUS'
                 else
                   "SHOW SLAVE '#{master_connection}' STATUS"
                 end
  begin
    raw_slave_status = execute_sql(status_query, nil, conn_options)
  rescue
    current_value_does_not_exist!
  end
  current_value_does_not_exist! if raw_slave_status.split("\n").count <= 1
  slave_status = parse_mysql_batch_result(raw_slave_status)
  slave_status.each do |row|
    master_host row['Master_Host']
    master_port row['Master_Port'].to_i
    master_user row['Master_User']
    master_log_file row['Master_Log_File']
    master_log_pos row['Read_Master_Log_Pos'].to_i
    master_use_gtid row['Using_Gtid'].nil? ? 'No' : row['Using_Gtid']
  end
  master_info_file = if master_connection.empty?
                       "#{data_dir}/master.info"
                     else
                       "#{data_dir}/master-#{master_connection}.info"
                     end
  master_password IO.readlines(master_info_file)[5].chomp
end

action_class do
  include MariaDBCookbook::Helpers

  def replication_query(query)
    ctrl = { user: new_resource.user, password: new_resource.password, host: new_resource.host, port: new_resource.port, socket: default_socket }
    if server_older_than?('10.0')
      raw_query = query
    else
      default_master_connection = new_resource.connection_name == 'default' ? '' : new_resource.connection_name
      raw_query = "SET @@default_master_connection='#{default_master_connection}';"
      raw_query << query
    end
    execute_sql(raw_query, nil, ctrl)
  end

  def mariadb_version
    ctrl = { user: new_resource.user, password: new_resource.password, host: new_resource.host, port: new_resource.port, socket: default_socket }
    parse_mysql_batch_result(execute_sql('SELECT VERSION()', nil, ctrl)).each do |row|
      return row['VERSION()'][/([\d\.]+)-MariaDB.*/, 1]
    end
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
    change_query = if server_older_than?('10.0') || new_resource.connection_name == 'default'
                     'CHANGE MASTER TO '
                   else
                     "CHANGE MASTER '#{new_resource.connection_name}' TO "
                   end
    master_settings = []
    master_attrs.each_pair do |attribute, value|
      master_settings << "#{attribute}=#{value}"
    end
    replication_query(change_query + master_settings.join(', '))
  end

  def slave_status?
    status_query = if server_older_than?('10.0') || new_resource.connection_name == 'default'
                     'SHOW SLAVE STATUS'
                   else
                     "SHOW SLAVE '#{new_resource.connection_name}' STATUS"
                   end
    begin
      slave_status_parsed = parse_mysql_batch_result(replication_query(status_query))
    rescue
      return false
    end
    slave_status_parsed
  end

  def start_slave
    if server_older_than?('10.0') || new_resource.connection_name == 'default'
      replication_query('START SLAVE')
    else
      replication_query("START SLAVE'#{new_resource.connection_name}'")
    end
  end

  def stop_slave
    if server_older_than?('10.0') || new_resource.connection_name == 'default'
      replication_query('STOP SLAVE')
    else
      replication_query("STOP SLAVE'#{new_resource.connection_name}'")
    end
  end
end
