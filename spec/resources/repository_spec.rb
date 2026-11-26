# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'mariadb_repository' do
  step_into :mariadb_repository
  platform 'centos-stream', '9'

  recipe { mariadb_repository 'install' }

  it 'uses the vendor RHEL repository on CentOS Stream' do
    expect(chef_run).to create_yum_repository('MariaDB 11.4').with(
      baseurl: 'https://dlm.mariadb.com/repo/mariadb-server/11.4/yum/rhel/$releasever/$basearch'
    )
  end
end
