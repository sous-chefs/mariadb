control 'mariadb_user' do
  impact 1.0
  title 'test creation, granting and removal of users'

  sql = mysql_session('root', 'gsql')

  describe sql.query('select User,Host from mysql.user') do
    its('output') { should match(/fozzie/) }
    its('output') { should_not match(/kermit/) }
  end

  describe sql.query("show grants for 'fozzie'@'mars'") do
    its('output') { should include '*EF112B3D562CB63EA3275593C10501B59C4A390D' }
    its('output') { should include 'GRANT SELECT, INSERT, UPDATE ON `databass`.* TO `fozzie`@`mars`' }
  end

  describe sql.query('show grants for  \'moozie\'@\'127.0.0.1\'') do
    its('output') { should include '*F798E7C0681068BAE3242AA2297D2360DBBDA62B' }
  end

  # sql2 = mysql_session('moozie', 'zokkazokka', '127.0.0.1')

  # TODO: https://github.com/inspec/inspec/pull/5219
  # describe sql2.query('show tables from databass') do
  #   its(:exit_status) { should eq 0 }
  # end

  describe sql.query('show grants for \'rowlf\'@\'localhost\'') do
    its('output') { should include '*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9' }
  end

  describe sql.query('show grants for \'statler\'@\'localhost\'') do
    its('output') { should include '*2027D9391E714343187E07ACB41AE8925F30737E' }
  end

  describe sql.query('select Host from mysql.user where User like \'gonzo\'') do
    its('output') { should include '10.10.10.%' }
  end

  describe sql.query('show grants for \'rizzo\'@\'127.0.0.1\'') do
    its('output') { should include '*125EA03B506F7C876D9321E9055F37601461E970' }
  end

  describe sql.query("show grants for 'spaces'@'127.0.0.1'") do
    its('output') { should include 'GRANT LOCK TABLES, REPLICATION CLIENT ON *.* TO `spaces`@`127.0.0.1`' }
  end
end
