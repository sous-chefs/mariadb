if defined?(ChefSpec)
  def add_mariadb_configuration(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_configuration, :add, resource_name)
  end

  def remove_mariadb_configuration(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_configuration, :remove, resource_name)
  end

  def add_mariadb_replication(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_replication, :add, resource_name)
  end

  def remove_mariadb_replication(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_replication, :remove, resource_name)
  end

  def install_mariadb_repository(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_repository, :install, resource_name)
  end

  def install_mariadb_client_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_client_install, :install, resource_name)
  end

  def install_mariadb_server_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_server_install, :install, resource_name)
  end

  def modify_mariadb_server_configuration(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_server_configuration, :modify, resource_name)
  end

  def create_mariadb_galera_configuration(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_galera_configuration, :create, resource_name)
  end

  def remove_mariadb_galera_configuration(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_galera_configuration, :remove, resource_name)
  end
end
