# mariadb_replication

It's used to manage replication setup on a host. To use it, the node need to have the mysql binary installed (via the mariadb_server_install or mariadb_client_install resource).

## Actions

- add - to add a new replication setup (become a slave)
- stop - to stop the slave replication
- start - to start the slave replication
- remove - to remove the slave replication configuration

## Properties

The resource name need to be 'default' if your don't want to use a named connection (multi source replication in MariaDB 10).

Name                                   | Types             | Description                                                   | Default                                   | Required?
---------------------------------------| ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`version`                              | String            | Version of MariaDB installed                                  | `10.3`                                    | no
`cookbook`                             | String            |                                                               | `mariadb`                                 | no
`connection_name`                      | String            | The resource name                                             |                                           | yes
`host`                                 | String, nil       |                                                               | `localhost`                               | no
`port`                                 | Integer, nil      |                                                               | `3306`                                    | no 
`user`                                 | String, nil       |                                                               | `root`                                    | no 
`password`                             | String, nil       |                                                               | `nil`                                     | no 
`change_master_while_running`          | true, false       |                                                               | `false`                                   | no 
`master_password`                      | String            |                                                               |                                           | yes 
`master_port`                          | Integer           |                                                               | `3306`                                    | no 
`master_use_gtid`                      | String            |                                                               | `No`                                      | no 
`master_host`                          | String            |                                                               |                                           | yes
`master_user`                          | String            |                                                               |                                           | yes
`master_connect_retry`                 | String            |                                                               |                                           | no
`master_log_pos`                       | Integer           |                                                               |                                           | no
`master_log_file`                      | String            |                                                               |                                           | no

## Examples

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
