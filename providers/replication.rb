#
# Cookbook Name:: mariadb
# Provider:: replication
#

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :add do
  sql_string = 'CHANGE MASTER '
  sql_string += '\'' + new_resource.name + \
    '\' ' if new_resource.name != 'default'
  sql_string += 'TO '
  sql_string += 'MASTER_HOST=\'' + new_resource.master_host + '\', '
  sql_string += 'MASTER_PORT=' + new_resource.master_port + \
    ', ' unless new_resource.master_port.nil?
  sql_string += 'MASTER_USER=\'' + new_resource.master_user + '\', '
  sql_string += 'MASTER_PASSWORD=\'' + new_resource.master_password + '\''
  if new_resource.master_use_gtid == 'no'
    # Use non GTID replication setup
    unless new_resource.master_log_file.nil?
      sql_string += ', MASTER_LOG_FILE=\'' + \
        new_resource.master_log_file + '\''
      sql_string += ', MASTER_LOG_POS=' + new_resource.master_log_pos
    end
  else
    # Use GTID replication
    sql_string += ', MASTER_USE_GTID=' + new_resource.master_use_gtid + ';'
  end
  execute 'add_replication_from_master_' + new_resource.name do
    command '/bin/echo "' + sql_string + '" | /usr/bin/mysql'
    action :run
  end
end

action :remove do
  execute 'remove_replication_from_master_' + new_resource.name do
    command '/bin/echo "STOP SLAVE \'' + new_resource.name + '\'; ' \
      'RESET SLAVE \'' + new_resource.name + '\' ALL; ' \
      ';" | /usr/bin/mysql'
  end
end
