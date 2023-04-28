#
# Cookbook:: mariadb
# Resource:: database
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
provides :mariadb_database
unified_mode true

include MariaDBCookbook::Helpers

property :database_name, String,         name_property: true
property :host,          [String, nil],  default: 'localhost', desired_state: false
property :port,          [Integer, nil], default: 3306, desired_state: false
property :user,          [String, nil],  default: 'root', desired_state: false
property :socket,        [String, nil], desired_state: false
property :password,      [String, nil], sensitive: true, desired_state: false
property :encoding, String, default: lazy { default_encoding }
property :collation, String, default: lazy { default_collation }
property :sql, String

action :create do
  if current_resource.nil?
    converge_by "Creating database '#{new_resource.database_name}'" do
      create_sql = "CREATE DATABASE IF NOT EXISTS \\`#{new_resource.database_name}\\`"
      create_sql << " CHARACTER SET = #{new_resource.encoding}" if new_resource.encoding
      create_sql << " COLLATE = #{new_resource.collation}" if new_resource.collation
      run_query(create_sql, nil)
    end
  else
    converge_if_changed :encoding do
      run_query("ALTER SCHEMA \\`#{new_resource.database_name}\\` CHARACTER SET #{new_resource.encoding}", nil)
    end
    converge_if_changed :collation do
      run_query("ALTER SCHEMA \\`#{new_resource.database_name}\\` COLLATE #{new_resource.collation}", nil)
    end
  end
end

action :drop do
  return if current_resource.nil?
  converge_by "Dropping database '#{new_resource.database_name}'" do
    run_query("DROP DATABASE IF EXISTS \\`#{new_resource.database_name}\\`", nil)
  end
end

action :query do
  run_query(new_resource.sql, nil)
end

load_current_value do
  ctrl = ctrl_hash(user, password, host, port, socket)
  query = "SHOW DATABASES LIKE '#{database_name}'"
  results = execute_sql(query, nil, ctrl).split("\n")
  current_value_does_not_exist! if results.count == 0

  results = execute_sql("SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '#{database_name}'", nil, ctrl)
  results.split("\n").each do |row|
    columns = row.split("\t")
    if columns[0] != 'DEFAULT_CHARACTER_SET_NAME'
      encoding  columns[0]
      collation columns[1]
    end
  end
end

action_class do
  include MariaDBCookbook::Helpers

  def ctrl
    ctrl_hash(
      new_resource.user, new_resource.password, new_resource.host, new_resource.port, new_resource.socket
    )
  end

  def run_query(query, database)
    Chef::Log.debug("#{@new_resource}: Performing query [#{query}]")
    execute_sql(query, database, ctrl)
  end
end
