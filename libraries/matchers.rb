if defined?(ChefSpec)
  def add_mariadb_configuration(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mariadb_configuration, :add, resource_name)
  end

  def remove_mariadb_configuration(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mariadb_configuration, :remove, resource_name)
  end
end
