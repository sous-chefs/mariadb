# Upgrading from v1.5

From v2.0.0 of the mariadb cookbook we have removed all recipes and most of the attributes from the cookbook.

## Deprecations

### Gem

Due to limitations in the gem compile process (libssl related) we have removed the mysql2_gem.

We no longer support accessing the database via the gem, and internally use the cli.

## Major Changes

Recipes are no longer supported so you should take a look at the examples in `test/cookbooks/test/recipes`

An example of how to

- Install the the server from the mariadb repository
- Install a database

```ruby
mariadb_repository 'install'

mariadb_server_install 'package'

mariadb_database 'test_1'
```
