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

  def create_mariadb_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_database, :create, resource_name)
  end

  def drop_mariadb_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_database, :drop, resource_name)
  end

  def query_mariadb_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_database, :query, resource_name)
  end

  def create_mariadb_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_user, :create, resource_name)
  end

  def drop_mariadb_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_user, :drop, resource_name)
  end

  def grant_mariadb_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_user, :grant, resource_name)
  end

  def revoke_mariadb_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher
      .new(:mariadb_user, :revoke, resource_name)
  end
end
