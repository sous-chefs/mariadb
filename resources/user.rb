#
# Cookbook:: mariadb
# Resource:: user
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

property :username,      String,                             name_property: true
property :password,      [String, HashedPassword, NilClass], default: nil,  sensitive: true
property :host,          String,                             default: 'localhost', desired_state: false
property :database_name, String
property :table,         String
property :privileges,    Array,                              default: [:all]
property :grant_option,  [TrueClass, FalseClass],            default: false
property :require_ssl,   [TrueClass, FalseClass],            default: false
property :require_x509,  [TrueClass, FalseClass],            default: false
# Credentials used for control connection
property :ctrl_user,     [String, NilClass],                 default: 'root', desired_state: false
property :ctrl_password, [String, NilClass],                 default: nil, sensitive: true, desired_state: false
property :ctrl_host,     [String, NilClass],                 default: 'localhost', desired_state: false
property :ctrl_port,     [Integer, NilClass],                default: 3306, desired_state: false

action :create do
  if current_resource.nil?
    converge_by "Creating user '#{new_resource.username}'@'#{new_resource.host}'" do
      create_sql = "CREATE USER '#{new_resource.username}'@'#{new_resource.host}'"
      if new_resource.password
        create_sql << ' IDENTIFIED BY '
        create_sql << if new_resource.password.is_a?(HashedPassword)
                        " PASSWORD '#{new_resource.password}'"
                      else
                        " '#{new_resource.password}'"
                      end
      end
      run_query create_sql
    end
  elsif !test_user_password
    update_user_password
  end
end

load_current_value do
  socket = ctrl_host == 'localhost' ? default_socket : nil
  ctrl = { user: ctrl_user, password: ctrl_password
         }.merge!(socket.nil? ? { host: ctrl_host, port: ctrl_port.to_s } : { socket: socket })
  query = "SELECT User,Host FROM mysql.user WHERE User='#{username}' AND Host='#{host}';"
  results = execute_sql(query, nil, ctrl)
  current_value_does_not_exist! if results.split("\n").count <= 1
end

action_class do
  include MariaDBCookbook::Helpers

  def run_query(query)
    socket = new_resource.ctrl_host == 'localhost' ? default_socket : nil
    ctrl_hash = { host: new_resource.ctrl_host, port: new_resource.ctrl_port, username: new_resource.ctrl_user, password: new_resource.ctrl_password, socket: socket }
    Chef::Log.debug("#{@new_resource}: Performing query [#{query}]")
    execute_sql(query, nil, ctrl_hash)
  end

  def database_has_password_column
    begin
      result = run_query("SHOW COLUMNS FROM mysql.user WHERE Field='Password';")
    rescue
      return false
    end
    result.split("\n").count > 1
  end

  def redact_password(query, password)
    if password.nil? || password == ''
      query
    else
      query.gsub(password.to_s, 'REDACTED')
    end
  end

  def test_user_password
    if database_has_password_column
      test_sql = 'SELECT User,Host,Password FROM mysql.user ' \
                       "WHERE User='#{new_resource.username}' AND Host='#{new_resource.host}' "
      test_sql << if new_resource.password.is_a? HashedPassword
                    "AND Password='#{new_resource.password}'"
                  else
                    "AND Password=PASSWORD('#{new_resource.password}')"
                  end
    else
      test_sql = 'SELECT User,Host,authentication_string FROM mysql.user ' \
                       "WHERE User='#{new_resource.username}' AND Host='#{new_resource.host}' " \
                       "AND plugin='mysql_native_password' "
      test_sql << if new_resource.password.is_a? HashedPassword
                    "AND authentication_string='#{new_resource.password}'"
                  else
                    "AND authentication_string=PASSWORD('#{new_resource.password}')"
                  end
    end
    run_query(test_sql).split("\n").count > 1
  end

  def update_user_password
    converge_by "Update password for user '#{new_resource.username}'@'#{new_resource.host}'" do
      if database_has_password_column
        password_sql = "SET PASSWORD FOR '#{new_resource.username}'@'#{new_resource.host}' = "
        password_sql << if new_resource.password.is_a? HashedPassword
                          "'#{new_resource.password}'"
                        else
                          " PASSWORD('#{new_resource.password}')"
                        end
      else
        # "ALTER USER is now the preferred statement for assigning passwords."
        # http://dev.mysql.com/doc/refman/5.7/en/set-password.html
        password_sql = "ALTER USER '#{new_resource.username}'@'#{new_resource.host}' "
        password_sql << if new_resource.password.is_a? HashedPassword
                          "IDENTIFIED WITH mysql_native_password AS '#{new_resource.password}'"
                        else
                          "IDENTIFIED BY '#{new_resource.password}'"
                        end
      end
      run_query password_sql
    end
  end

  def desired_privs
    possible_global_privs = [
      :select,
      :insert,
      :update,
      :delete,
      :create,
      :drop,
      :references,
      :index,
      :alter,
      :create_tmp_table,
      :lock_tables,
      :create_view,
      :show_view,
      :create_routine,
      :alter_routine,
      :execute,
      :event,
      :trigger,
      :reload,
      :shutdown,
      :process,
      :file,
      :show_db,
      :super,
      :repl_slave,
      :repl_client,
      :create_user,
    ]
    possible_db_privs = [
      :select,
      :insert,
      :update,
      :delete,
      :create,
      :drop,
      :references,
      :index,
      :alter,
      :create_tmp_table,
      :lock_tables,
      :create_view,
      :show_view,
      :create_routine,
      :alter_routine,
      :execute,
      :event,
      :trigger,
    ]

    # convert :all to the individual db or global privs
    desired_privs = if new_resource.privileges == [:all] && new_resource.database_name
                      possible_db_privs
                    elsif new_resource.privileges == [:all]
                      possible_global_privs
                    else
                      new_resource.privileges
                    end
    desired_privs
  end

  def get_clean_grant_right_name(key)
    return '' if key.nil?

    # Some keys need to be translated as outlined by the table found here:
    # https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html
    result = key.to_s.downcase.tr('_', ' ').gsub('repl ', 'replication ').gsub('create tmp table', 'create temporary tables').gsub('show db', 'show databases')
    result = result.gsub(/ priv$/, '')
    result
  end
end

action :drop do
  return if current_resource.nil?
  converge_by "Dropping user '#{new_resource.username}'@'#{new_resource.host}'" do
    drop_sql = 'DROP USER'
    drop_sql << " '#{new_resource.username}'@'#{new_resource.host}'"
    run_query drop_sql
  end
end

action :grant do
  db_name = new_resource.database_name ? "\\`#{new_resource.database_name}\\`" : '*'
  tbl_name = new_resource.table || '*'
  test_table = new_resource.database_name ? 'mysql.db' : 'mysql.user'

  # Test
  privs_to_grant = []
  test_sql = "SELECT * from #{test_table}"
  test_sql << " WHERE User='#{new_resource.username}'"
  test_sql << " AND Host='#{new_resource.host}'"
  test_sql << " AND Db='#{new_resource.database_name}'" if new_resource.database_name
  test_sql_results = run_query test_sql

  if test_sql_results.split("\n").count == 0
    privs_to_grant = desired_privs.map { |p| get_clean_grant_right_name(p) }
  else
    # These should all be 'Y'
    parsed_result = parse_mysql_batch_result(test_sql_results)
    Chef::Log.debug(parsed_result)
    parsed_result.each do |r|
      desired_privs.each do |p|
        key = p.to_s.capitalize.tr(' ', '_').gsub('Replication_', 'Repl_').gsub('Create_temporary_tables', 'Create_tmp_table').gsub('Show_databases', 'Show_db')
        key = "#{key}_priv"
        privs_to_grant << get_clean_grant_right_name(p) if r[key] != 'Y'
      end
    end
  end

  # Repair
  if privs_to_grant.empty?
    # The grants are correct, but perhaps the password needs updating?
    update_user_password unless test_user_password
  else
    converge_by "Granting privs for '#{new_resource.username}'@'#{new_resource.host}'" do
      grant_statement = "GRANT #{privs_to_grant.join(',')}"
      grant_statement << " ON #{db_name}.#{tbl_name}"
      grant_statement << " TO '#{new_resource.username}'@'#{new_resource.host}' IDENTIFIED BY"
      grant_statement << if new_resource.password.is_a?(HashedPassword)
                           " PASSWORD '#{new_resource.password}'"
                         else
                           " '#{new_resource.password}'"
                         end
      grant_statement << ' REQUIRE SSL' if new_resource.require_ssl
      grant_statement << ' REQUIRE X509' if new_resource.require_x509
      grant_statement << ' WITH GRANT OPTION' if new_resource.grant_option

      redacted_sql = redact_password(grant_statement, new_resource.password)
      Chef::Log.debug("#{@new_resource}: granting with sql [#{redacted_sql}]")
      run_query(grant_statement)
      run_query('FLUSH PRIVILEGES')
    end
  end
end

action :revoke do
  db_name = new_resource.database_name ? "\\`#{new_resource.database_name}\\`" : '*'
  tbl_name = new_resource.table || '*'
  test_table = new_resource.database_name ? 'mysql.db' : 'mysql.user'

  privs_to_revoke = []
  test_sql = "SELECT * from #{test_table}"
  test_sql << " WHERE User='#{new_resource.username}'"
  test_sql << " AND Host='#{new_resource.host}'"
  test_sql << " AND Db='#{new_resource.database_name}'" if new_resource.database_name
  test_sql_results = run_query test_sql

  # These should all be 'N'
  parsed_result = parse_mysql_batch_result(test_sql_results)
  Chef::Log.debug(parsed_result)
  parsed_result.each do |r|
    desired_privs.each do |p|
      key = p.to_s.capitalize.tr(' ', '_').gsub('Replication_', 'Repl_').gsub('Create_temporary_tables', 'Create_tmp_table').gsub('Show_databases', 'Show_db')
      key = "#{key}_priv"
      privs_to_revoke << get_clean_grant_right_name(p) if r[key] != 'N'
    end
  end

  # Repair
  unless privs_to_revoke.empty?
    converge_by "Revoking privs for '#{new_resource.username}'@'#{new_resource.host}'" do
      revoke_statement = "REVOKE #{privs_to_revoke.join(',')}"
      revoke_statement << " ON #{db_name}.#{tbl_name}"
      revoke_statement << " FROM \\`#{new_resource.username}\\`@\\`#{new_resource.host}\\` "

      Chef::Log.debug("#{@new_resource}: revoking access with statement [#{revoke_statement}]")
      run_query revoke_statement
      run_query 'FLUSH PRIVILEGES'
    end
  end
end
