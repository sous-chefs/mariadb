MariaDB Cookbook
================

[![Build Status](https://travis-ci.org/sous-chefs/mariadb.svg?branch=master)](https://travis-ci.org/sous-chefs/mariadb) [![Cookbook Version](https://img.shields.io/cookbook/v/mariadb.svg)](https://supermarket.chef.io/cookbooks/mariadb)

Description
-----------

This cookbook contains all the stuffs to install and configure and manage a mariadb server on a dpkg/apt compliant system (typically debian), or a rpm/yum compliant system (typically centos)


Requirements
------------

#### repository
- `mariadb` - This cookbook need that you have a valid apt repository installed with the mariadb official packages

#### packages
- `percona-xtrabackup` - if you want to use the xtrabckup SST Auth for galera cluster.
- `mariadb-backup` - if you want to use the mariabackup SST Auth for galera cluster.
- `socat` - if you want to use the xtrabckup or mariabackup SST Auth for galera cluster.
- `rsync` - if you want to use the rsync SST Auth for galera cluster.
- `debconf-utils` - if you use debian platform family.

#### operating system
- `debian` - this cookbook is fully tested on debian
- `ubuntu` - this cookbook is fully tested on ubuntu
- `centos` - this cookbook is fully tested on centos

#### Chef version
Since version 1.5.4 of this cookbook, the chef 12 support is dropped (chef 12 has reached end of life). Now chef 13 is the minimum version tested.
If you can't upgrade your chef 12, please use the version 1.5.3 or earlier of this cookbook.

Attributes
----------

#### mariadb::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['mariadb']['install']['version']</tt></td>
    <td>String</td>
    <td>Version to install (currently 10.0 et 5.5)</td>
    <td><tt>10.0</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['use_default_repository']</tt></td>
    <td>Boolean</td>
    <td>Whether to install MariaDB default repository or not. If you don't have a local repo containing packages, put it to true</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['server_root_password']</tt></td>
    <td>String</td>
    <td>local root password</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['forbid_remote_root']</tt></td>
    <td>Boolean</td>
    <td>Whether to activate root remote access</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['allow_root_pass_change']</tt></td>
    <td>Boolean</td>
    <td>Whether to allow the recipe to change root password after the first install</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['client']['development_files']</tt></td>
    <td>Boolean</td>
    <td>Whether to install development files in client recipe</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['apt_repository']['base_url']</tt></td>
    <td>String</td>
    <td>The http base url to use when installing from default repository</td>
    <td><tt>'ftp.igh.cnrs.fr/pub/mariadb/repo'</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['install']['prefer_os_package']</tt></td>
    <td>Boolean</td>
    <td>Indicator for preferring use packages shipped by running os</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['install']['prefer_scl_package']</tt></td>
    <td>Boolean</td>
    <td>Indicator for preferring packages from software collections repository</td>
    <td><tt>false</tt></td>
  </tr>
</table>

Usage
-----

To install a default server for mariadb choose the version you want (MariaDB 5.5 or 10, galera or not), then call the recipe accordingly.

List of availables recipes:

- mariadb::default (just call server recipe with default options)
- mariadb::server
- mariadb::galera
- mariadb::client
- mariadb::devel

Please be ware that by default, the root password is empty! If you want have changed it use the `node['mariadb']['server_root_password']` attribute to put a correct value. And by default the remote root access is not activated. Use `node['mariadb']['forbid_remote_root']` attribute to change it.

Sometimes, the default apt repository used for apt does not work (see issue #6). In this case, you need to choose another mirror which worki (pick it from mariadb website), and put the http base url in the attribute `node['mariadb']['apt_repository']['base_url']`.

#### mariadb::galera

When installing the mariadb::galera on debian recipe, You have to take care of one specific attribute:
`node['mariadb']['debian']['password']` which default to 'please-change-me'
As wee need to have the same password for this user on the whole cluster nodes... We will change the default install one by the content of this attribute.

#### mariadb::client

By default this recipe installs the client, and all needed packages to develop client application. If you do not want to install development files when installing client package,
set the attribute `node['mariadb']['client']['development_files']` to false. 

#### mariadb::devel

By default this recipe installs all needed packages to develop client application.

Resources/Providers
----------

This recipe define several custom resources and providers:
- `Chef::Provider::Mariadb::Configuration` shortcut resource `mariadb_configuration`

#### mariadb_configuration

Mainly use for internal purpose. You can use it to create a new configuration file into configuration dir. You have to define 2 variables `section` and `option`.
Where `section` is the configuration section, and `option` is a hash of key/value. The name of the resource is used as base for the filename.

Example:
```ruby
mariadb_configuration 'fake' do
  section 'mysqld'
  option :innodb_buffer_pool_size => node['mysql']['innodb_buffer_pool_size'],
    :innodb_flush_method => node['mysql']['innodb_flush_method']
end
```
will become the file fake.cnf in the include dir (depend on your platform), which contain:
```
[mysqld]
foo=bar
```

If the value start with a '#', then it's considered as a comment, and the value is printed as is (without the key)

Example:
```ruby
mariadb_configuration 'fake' do
  section 'mysqld'
  option :comment1 => '# Here i am',
    :foo => bar
end
```
will become the file fake.cnf in the include dir (depend on your platform), which contain:
```
[mysqld]
# Here i am
foo=bar
```

#### mariadb_replication

This LWRP is used to manage replication setup on a host. To use this LWRP, the node need to have the mysql binary installed (via the mariadb::client or mariadb::server or mariadb::galera recipe).
It have 4 actions:
- add - to add a new replication setup (become a slave)
- stop - to stop the slave replication
- start - to start the slave replication
- remove - to remove the slave replication configuration

The resource name need to be 'default' if your don't want to use a named connection (multi source replication in MariaDB 10).

So by default the provider try to use the local instance of mysql, with the current root and password set in attribute node['mariadb']['server_root_password']. If you want to change, you have to define `host`, `port`, `user` or `password`

```ruby
mariadb_replication 'default' do
  user 'root'
  password 'fakepass'
  host 'fakehost'
  action :stop
end
```
will stop the replication on the host `fakehost` using the user `root` and password `fakepass` to connect to.

When you add a replication configuration, you have to define at least 4 values `master_host`, `master_user`, `master_password` and `master_use_gtid`. And if you don't want the GTID support, you have to define also `master_log_file` and `master_log_pos`

Example:
```ruby
mariadb_replication 'usefull_conn_name' do
  master_host 'server1'
  master_user 'slave_user'
  master_password 'slave_password'
  master_use_gtid 'current_pos'
  action :add
end
```

By default, resource doesn't change master if slave is running. If you want to let resource change slave settings for replication channel while slave is running use `change_master_while_running` property. When it's set to `true` slave settings will be changed
if either one of `master_host`, `master_port`, `master_user`, `master_password` and `master_use_gtid` was changed.

Changes of only `master_log_file` and/or `master_log_pos` don't affect server if slave is already configured.

#### mariadb_database

Manage databases and execute SQL queries on them. It works by establishing a control connection to the MariaDB server using the `mysql2` chef gem (automatically installed). It has 3 actions:
- create - to create a named database
- drop - to drop a named database
- query - to execute a SQL query

##### Syntax

The full syntax of all of the properties that are available to the `mariadb_database` resource is: 

```ruby
mariadb_database 'name' do
  # Credentials for the control connection
  user                       String # defaults to 'root'
  host                       String # defaults to 'localhost'
  port                       String # defaults to node['mariadb']['mysqld']['port']
  password                   String # defaults to node['mariadb']['server_root_password'] 
  # The database to be managed
  database_name              String # defaults to 'name' if not specified
  encoding                   String # defaults to 'utf8'
  collation                  String # defaults to 'utf8_general_ci'
  sql                        String, Proc # the SQL query to execute 
  action                     Symbol # defaults to :create if not specified
end
```

When `host` has the value `localhost`, it will try to connect using the Unix socket defined in `node['mariadb']['client']['socket']`, or TCP/IP if no socket is defined.

##### Examples

```ruby
# Create a database
mariadb_database 'wordpress-cust01' do
  host '127.0.0.1'
  user 'root'
  password node['wordpress-cust01']['mysql']['initial_root_password']
  action :create
end
 
# Drop a database
mariadb_database 'baz' do
  action :drop
end
 
# Query a database
mariadb_database 'flush the privileges' do
  sql 'flush privileges'
  action :query
end
```

The `query` action will NOT select a database before running the query, nor return the actual results from the SQL query.

#### mariadb_user

Manage users and grant them privileges on database objects. It works by establishing a control connection to the MariaDB server using the `mysql2` chef gem (automatically installed). It has 4 actions:
- create - to create a user
- drop - to drop a user
- grant - to grant privileges to a user
- revoke - to revoke privileges from a user

##### Syntax

The full syntax of all of the properties that are available to the `mariadb_user` resource is: 

```ruby
mariadb_user 'name' do
  # Credentials for the control connection
  ctrl_user                  String # defaults to 'root'
  ctrl_host                  String # defaults to 'localhost'
  ctrl_port                  String # defaults to node['mariadb']['mysqld']['port']
  ctrl_password              String # defaults to node['mariadb']['server_root_password'] 
  # The user to be managed
  username                   String # defaults to 'name'
  host                       String # defaults to 'localhost'
  password                   String, HashedPassword
  # The privileges to be granted/revoked
  privileges                 Array # defaults to [:all]
  database_name              String # to grant/revoke privileges on a database 
  table                      String # to grant/revoke privileges on a particular database table
  grant_option               true|false # defaults to false 
  require_ssl                true|false # defaults to false
  require_x509               true|false # defaults to false 
  action                     Symbol # defaults to :create if not specified
end
```

##### Examples

```ruby
# Create an user but grant no privileges
mariadb_user 'disenfranchised' do
  password 'super_secret'
  action :create
end
 
# Create an user using a hashed password string instead of plain text one
mariadb_user 'disenfranchised' do
  password hashed_password('md5eacdbf8d9847a76978bd515fae200a2a')
  action :create
end

# Drop a user
mariadb_user 'foo_user' do
  action :drop
end

# Grant SELECT, UPDATE, and INSERT privileges to all tables in foo db from all hosts
mariadb_user 'foo_user' do
  password 'super_secret'
  database_name 'foo'
  host '%'
  privileges [:select,:update,:insert]
  action :grant
end
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors:
Nicolas Blanc <sinfomicien@gmail.com>
