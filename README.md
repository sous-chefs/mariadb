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

If you are wondering where all the recipes went in v2.0+, or how on earth I use this new cookbook please see [upgrading.md](https://github.com/sous-chefs/mariadb/blob/master/documentation/upgrading.md) for a full description.

## Resources

- [`repository`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_repository.md)
- [`client_install`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_client_install.md)
- [`server_install`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_server_install.md)
- [`configuration`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_configuration.md)
- [`server_configuration`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_server_configuration.md)
- [`galera_configuration`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_galera_configuration.md)
- [`replication`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_replication.md)
- [`user`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_user.md)
- [`database`](https://github.com/sous-chefs/mariadb/blob/master/documentation/resource_mariadb_database.md)

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

## Contributors

This project exists thanks to all the people who contribute.
<img src="https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false" /></a>


### Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/sous-chefs#backer)]
<a href="https://opencollective.com/sous-chefs#backers" target="_blank"><img src="https://opencollective.com/sous-chefs/backers.svg?width=890"></a>

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/sous-chefs#sponsor)]
<a href="https://opencollective.com/sous-chefs/sponsor/0/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/1/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/2/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/3/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/4/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/5/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/6/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/7/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/8/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/sous-chefs/sponsor/9/website" target="_blank"><img src="https://opencollective.com/sous-chefs/sponsor/9/avatar.svg"></a>
