# mariadb_galera_configuration

Do all configuration to have a working Galera Cluster

## Actions

- `create` - (default) Create & Maintain the configuration file
- `remove` - Remove the galera configuration file

## Properties

Name                                   | Types             | Description                                                   | Default                                   | Required?
---------------------------------------| ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`cluster_name`                         | String            |                                                               | `galera_cluster`                          | no
`cluster_nodes`                        ï Array             |                                                               | `[]`                                      | no
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

(1) `ext_conf_dir` is a helper method which return the extra configuration directory based on OS flavor

## Examples

If you use a chef-server, set an attribute within your cookbook to determine which nodes belong to the cluster. If your cookbook is 'mycookbook' set:

```ruby
default['mycookbook']['galera']['cluster_name'] = 'my_cluster_name'
```

Then all nodes to add to gcomm will be choosen with a search based on this attribute:

```ruby
mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
  version '10.3'
  cluster_name 'my_cluster_name'
  cluster_search_query "mycookbook_galera_cluster_name:my_cluster_name"
end
```

If you don't want to have a dynamic node galera node management, set manually the gcomm_address with all nodes you want in it:

```ruby
mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
  version '10.3'
  cluster_name 'my_cluster_name'
  gcomm_address 'gcomm://node1.fqdn,node2.fqdn'
end
```
