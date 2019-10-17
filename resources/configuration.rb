# frozen_string_literal: true
#
# Cookbook:: mariadb
# Resource:: configuration
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

# name of the extra conf file, used for .cnf filename
property :configuration_name, String, name_property: true
property :section,            String, required: true
property :option,             Hash,   required: true
property :cookbook,           String,                 default: 'mariadb'
property :extconf_directory,  String,                 default: lazy { ext_conf_dir }

action :add do
  variables_hash = {
    section: new_resource.section,
    options: new_resource.option,
  }
  template ::File.join(new_resource.extconf_directory, new_resource.configuration_name + '.cnf') do
    source 'conf.d.generic.erb'
    owner 'root'
    group 'mysql'
    mode '0640'
    cookbook new_resource.cookbook
    variables variables_hash
    sensitive true
  end
end

action :remove do
  if ::File.exist?(::File.join(new_resource.extconf_directory, new_resource.configuration_name + '.cnf'))
    Chef::Log.info "Removing #{new_resource.configuration_name} configuration from #{new_resource.extconf_directory}/#{new_resource.configuration_name}.cnf"
    file ::File.join(new_resource.extconf_directory, new_resource.configuration_name + '.cnf') do
      action :delete
    end
  end
end

action_class do
  include MariaDBCookbook::Helpers
end
