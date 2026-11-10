require 'spec_helper'

RSpec.describe 'mariadb_user' do
  step_into :mariadb_user
  platform 'debian', '12'

  let(:queries) { [] }
  let(:grant_row) { "User\tHost\tDb\tSelect_priv\ntest_user\tlocalhost\ttest_db\t#{select_priv}" }
  let(:select_priv) { 'N' }

  before do
    stubs_for_resource('mariadb_user[test_user]') do |resource|
      allow(resource).to receive(:execute_sql) { |query, _database, _ctrl| sql_response(query) }
    end

    stubs_for_provider('mariadb_user[test_user]') do |provider|
      allow(provider).to receive(:execute_sql) { |query, _database, _ctrl| sql_response(query) }
      allow(provider).to receive(:mariadb_version).and_return(Gem::Version.new('11.4'))
    end
  end

  context 'when grants need repair and password is omitted' do
    recipe do
      mariadb_user 'test_user' do
        database_name 'test_db'
        privileges [:select]
        action :grant
      end
    end

    it 'grants privileges without changing authentication' do
      subject

      grant_sql = queries.find { |query| query.start_with?('GRANT') }
      expect(grant_sql).to eq("GRANT SELECT ON \\`test_db\\`.* TO 'test_user'@'localhost'")
      expect(grant_sql).not_to include('IDENTIFIED BY')
    end
  end

  context 'when grants are already correct and password is omitted' do
    let(:select_priv) { 'Y' }

    recipe do
      mariadb_user 'test_user' do
        database_name 'test_db'
        privileges [:select]
        action :grant
      end
    end

    it 'does not test or update the password' do
      subject

      expect(queries).not_to include(match(/SHOW COLUMNS FROM mysql\.user/))
      expect(queries).not_to include(match(/(?:Password|authentication_string)=/))
      expect(queries).not_to include(match(/(?:SET PASSWORD|ALTER USER)/))
    end
  end

  context 'when grants need repair and password is supplied' do
    recipe do
      mariadb_user 'test_user' do
        database_name 'test_db'
        privileges [:select]
        password 'secret'
        action :grant
      end
    end

    it 'preserves password assignment through the grant statement' do
      subject

      expect(queries).to include("GRANT SELECT ON \\`test_db\\`.* TO 'test_user'@'localhost' IDENTIFIED BY 'secret'")
    end
  end

  context 'when grants are already correct and password is supplied' do
    let(:select_priv) { 'Y' }

    recipe do
      mariadb_user 'test_user' do
        database_name 'test_db'
        privileges [:select]
        password 'secret'
        action :grant
      end
    end

    it 'preserves password reconciliation' do
      subject

      expect(queries).to include("SET PASSWORD FOR 'test_user'@'localhost' =  PASSWORD('secret')")
    end
  end

  def sql_response(query)
    queries << query

    case query
    when /SELECT User,Host FROM mysql\.user/
      "User\tHost\ntest_user\tlocalhost"
    when /SELECT \* from mysql\.db/
      grant_row
    when /SHOW COLUMNS FROM mysql\.user/
      "Field\tType\nPassword\tlongtext"
    else
      ''
    end
  end
end
