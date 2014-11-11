node['mariadb']['plugins'].each do |plugin, enable|
  include_recipe '#{cookbook_name}::' + plugin + '_plugin' if enable
end
