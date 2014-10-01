#
# Cookbook Name:: mariadb
# Resource:: replication
#

actions :add, :remove
default_action :add

# name of the extra conf file, used for .cnf filename
attribute :connection_name, kind_of: String, name_attribute: true
attribute :master_host, kind_of: String, required: true
attribute :master_user, kind_of: String, required: true
attribute :master_password, kind_of: String, required: true
attribute :master_connect_retry, kind_of: [String, nil], default: nil
attribute :master_port, kind_of: [Integer, nil], default: nil
attribute :master_log_pos, kind_of: [Integer, nil], default: nil
attribute :master_log_file, kind_of: [String, nil], default: nil
attribute :master_use_gtid, kind_of: String, default: 'no'
