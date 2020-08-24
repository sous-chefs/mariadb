control 'mariadb_database' do
  impact 1.0
  title 'test creation and removal of databases'

  sql = mysql_session('root', 'gsql')

  describe sql.query('show databases') do
    its('stderr') { should match(/databass/) }
    its('stderr') { should_not match(/datatrout/) }
  end
end
