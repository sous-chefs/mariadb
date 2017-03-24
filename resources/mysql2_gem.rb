provides :mysql2_gem
resource_name :mysql2_gem

property :compile_time, [true, false], default: false

default_action :install

action :install do
  include_recipe 'mariadb::devel'
  build_essential 'install_packages'
  gem_package 'mysql2'
end

action :remove do
  gem_package 'mysql2' do
    action :remove
  end
end

def after_created
  return unless compile_time
  Array(action).each do |action|
    run_action(action)
  end
end
