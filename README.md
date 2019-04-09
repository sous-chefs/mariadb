MariaDB Cookbook
================

[![Cookbook Version](https://img.shields.io/cookbook/v/mariadb.svg)](https://supermarket.chef.io/cookbooks/mariadb)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/mariadb/master.svg)](https://circleci.com/gh/sous-chefs/mariadb)

## Description

This cookbook contains all the stuffs to install and configure and manage a mariadb server on a dpkg/apt compliant system (typically debian), or a rpm/yum compliant system (typically centos)


## Requirements

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
Since version 2.0.0 of this cookbook, chef 13 support is dropped. New chef 14 is the minimum version tested.
If you can't upgrade your chef 13, please user the version 1.5.4 or earlier of this cookbook.

## Upgrading

If you are wondering where all the recipes went in v2.0+, or how on earth I use this new cookbook please see [upgrading.md](documentation/upgrading.md) for a full description.

## Resources

- [`repository`](documentation/resource_mariadb_repository.md)
- [`client_install`](documentation/resource_mariadb_client_install.md)
- [`server_install`](documentation/resource_mariadb_server_install.md)
- [`configuration`](documentation/resource_mariadb_configuration.md)
- [`server_configuration`](documentation/resource_mariadb_server_configuration.md)
- [`galera_configuration`](documentation/resource_mariadb_galera_configuration.md)
- [`replication`](documentation/resource_mariadb_replication.md)
- [`user`](documentation/resource_mariadb_user.md)
- [`database`](documentation/resource_mariadb_database.md)

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
