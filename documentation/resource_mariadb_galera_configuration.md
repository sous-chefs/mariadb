# mariadb_galera_configuration

Do all configuration to have a working Galera Cluster.

## Actions

- `create` - (default) creates and maintains the Galera configuration file
- `bootstrap` - bootstraps a new Galera cluster
- `join` - joins an existing Galera cluster
- `remove` - removes the galera configuration file

## Properties

Name                                   | Types             | Description                                                   | Default                                   | Required?
-------------------------------------- | ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`cluster_name`                         | String            |                                                               | `galera_cluster`                          | no
`cluster_nodes`                        | Array             |                                                               | `[]`                                      | no
`cluster_search_query`                 | String, NilClass  |                                                               | `nil`                                     | no
`cookbook`                             | String            |                                                               | `mariadb`                                 | no
`extra_configuration_directory`        | String            |                                                               | `ext_conf_dir` (1)                        | no
`gcomm_address`                        | String            |                                                               | `nil`                                     | no
`innodb_flush_log_at_trx_commit`       | Integer           |                                                               | `2`                                       | no
`options`                              | Hash              |                                                               | `{}`                                      | no
`server_id`                            | Integer           |                                                               | `100`                                     | no
`version`                              | String            | Version of MariaDB installed                                  | `10.3`                                    | no
`wsrep_node_address_interface`         | String, NilClass  |                                                               | `nil`                                     | no
`wsrep_node_incoming_address_interface`| String, NilClass  |                                                               | `nil`                                     | no
`wsrep_node_port`                      | Integer, NilClass |                                                               | `nil`                                     | no
`wsrep_provider_options`               | Hash              |                                                               | `{'gcache.size': '512M'}`                 | no
`wsrep_provider`                       | String            |                                                               | `/usr/lib/galera/libgalera_smm.so`        | no
`wsrep_slave_threads`                  | String            | By default the MariaDB recommended value is set (nb_cpu * 4)  | `%{auto}`                                 | no
`wsrep_sst_auth`                       | String            |                                                               | `sstuser:some_secret_password`            | no
`wsrep_sst_method`                     | String            | Can be 'rsync', 'xtrabackup' or 'mariabackup'                 | `rsync`                                   | no

1. `ext_conf_dir` is a helper method which return the extra configuration directory based on OS flavor.

## Examples

### Managing the Galera Cluster address (`gcomm://`)

These examples show how to set the cluster address in the config file by either using a Chef search or providing a static value. Note that this example will not result in a bootstrap cluster.

If you use a Chef server, set an attribute within your cookbook to determine which nodes belong to the cluster. If your cookbook is 'mycookbook' set:

```ruby
default['mycookbook']['galera']['cluster_name'] = 'my_cluster_name'
```

Then use a Chef search to find other nodes and add these hosts to the gcomm address:

```ruby
mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
  version '10.3'
  cluster_name 'my_cluster_name'
  cluster_search_query "mycookbook_galera_cluster_name:my_cluster_name"
end
```

If you don't want to have a dynamic node galera node management, you can manually the gcomm address:

```ruby
mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
  version '10.3'
  cluster_name 'my_cluster_name'
  gcomm_address 'gcomm://node1.fqdn,node2.fqdn'
end
```

### Bootstrapping a new cluster and joining additional nodes

Out the box, MariaDB does not bootstrap a Galera cluster. In addition to bootstrapping the cluster, Chef will also set a `node['mariadb']['galera']['bootstrapped']` attribute with a `true` value so that you can search for nodes that have successfully joined a cluster.

Following on from the previous example, to do this you should specific the `:bootstrap` action:

```
mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
  version '10.3'
  cluster_name 'my_cluster_name'
  cluster_search_query "mycookbook_galera_cluster_name:my_cluster_name AND mariadb_galera_bootstrapped:true"
  action [:create, :bootstrap]
end
```

This should only be done by one node in cluster you're going to create, other nodes will want to use the `:join` action to join the cluster:

```
mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
  version '10.3'
  cluster_name 'my_cluster_name'
  cluster_search_query "mycookbook_galera_cluster_name:my_cluster_name AND mariadb_galera_bootstrapped:true"
  action [:create, :join]
end
```

Now any joiner nodes will attempt to join the bootstap node each time Chef runs until it is successful.
