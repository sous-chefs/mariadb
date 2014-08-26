mariadb Cookbook
==============

This cookbook contains all the stuffs to install and configure a mariadb server on a dpkg compliant system (typically debian)


Requirements
------------

#### repository
- `mariadb` - This cookbook need that you have a valid apt repository installed with th mariadn official package

#### packages
- `percona-xtrabackup` - if you want to use the xtrabckup SST Auth for galera cluster.
- `socat` - if you want to use the xtrabckup SST Auth for galera cluster.
- `rsync` - if you want to use the rsync SST Auth for galera cluster.

#### operating system
- `debian` - this cookbook is fully tested on debian
- `ubuntu` - not tested on ubuntu, but should work

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
    <td><tt>['mariadb']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----

To install a default server for mariadb choose the version you want (MariaDB 5.5 or 10, galera or not), then call the recipe accordingly.

List of availables recipes:

- mariadb::10
- mariadb::55
- mariadb::galera10
- mariadb::galera55

Contributing
------------

1. Fork the repository on Stash
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Stash

License and Authors
-------------------
Authors:
Nicolas Blanc <nicolas.blanc@blablacar.com>
