#
# Cookbook Name:: mariadb
# Provider:: extraconf
#

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :add do
  variables_hash = {
    section: new_resource.section,
    options: new_resource.option
  }
  template "/etc/mysql/conf.d/#{new_resource.name}.cnf" do
    owner 'root'
    group 'mysql'
    mode '0640'
    variables variables_hash
  end
end

action :remove do
  if ::File.exist?("/etc/mysql/conf.d/#{new_resource.name}.cnf")
    Chef::Log.info "Removing #{new_resource.name} repository from " + \
      '/etc/mysql/conf.d/'
    file "/etc/mysql/conf.d/#{new_resource.name}.cnf" do
      action :delete
    end
  end
end
