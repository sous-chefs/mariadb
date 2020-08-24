control 'mariadb_database' do
  impact 1.0
  title 'test creation and removal of databases'

  sql = mysql_session('root', 'gsql')

  describe sql.query('show databases') do
    its('output') { should match(/databass/) }
    its('output') { should_not match(/datatrout/) }
  end
end
