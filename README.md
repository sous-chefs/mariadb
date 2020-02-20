# MariaDB Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/mariadb.svg)](https://supermarket.chef.io/cookbooks/mariadb)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/mariadb/master.svg)](https://circleci.com/gh/sous-chefs/mariadb)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

This cookbook contains all the stuffs to install and configure and manage a mariadb server on a dpkg/apt compliant system (typically debian), or a rpm/yum compliant system (typically centos)

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### repository

- `mariadb` - This cookbook need that you have a valid apt repository installed with the mariadb official packages

### packages

- `percona-xtrabackup` - if you want to use the xtrabckup SST Auth for galera cluster.
- `mariadb-backup` - if you want to use the mariabackup SST Auth for galera cluster.
- `socat` - if you want to use the xtrabckup or mariabackup SST Auth for galera cluster.
- `rsync` - if you want to use the rsync SST Auth for galera cluster.
- `debconf-utils` - if you use debian platform family.

### operating system

- `debian` - this cookbook is fully tested on debian
- `ubuntu` - this cookbook is fully tested on ubuntu
- `centos` - this cookbook is fully tested on centos

### Chef version

Since version 2.0.0 of this cookbook, chef 13 support is dropped. New chef 14 is the minimum version tested.
If you can't upgrade your chef 13, please use the version 1.5.4 or earlier of this cookbook.

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

## Contributing

1. Fork the repository on Github
1. Create a named feature branch (like `add_component_x`)
1. Write your change
1. Write tests for your change (if applicable)
1. Run the tests, ensuring they all pass
1. Submit a Pull Request using Github

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
