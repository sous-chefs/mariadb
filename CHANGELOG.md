mariadb CHANGELOG
===============

This file is used to list changes made in each version of the mariadb cookbook.

0.2.0
-----
- [nicolas.blanc] -  Add rpm/yum management
- [nicolas.blanc] -  Refactor the whole recipes list and management to ease it
- [nicolas.blanc] -  Correct the Documentation
- [nicolas.blanc] -  Rename the provider (from extraconf to configuration), and add matchers to it
- [nicolas.blanc] -  Add a recipe to manage client only installation
- [nicolas.blanc] -  Refactor all tests to manage new platform (centos/redhat/fedora)

0.1.8
-----
- [nicolas.blanc] -  Add ignore-failure to debian grants correct, as it can break on initial setup

0.1.7
-----
- [nicolas.blanc] -  Correct a typo (unnecessary call to run_command)

0.1.6
-----
- [nicolas.blanc] -  improve Galera configuration management
- [nicolas.blanc] -  Add new rspec tests
- [nicolas.blanc] -  Create Kitchen test suite

0.1.5
-----
- [nicolas.blanc] -  improve attributes management

0.1.4
-----
- [nicolas.blanc] - adapt galera55 recipe to use a generic galera recipe
- [nicolas.blanc] - use a generic galera recipe to create the galera10 recipe
- [nicolas.blanc] - Improve documentation 


0.1.0
-----
- [nicolas.blanc] - Initial release of mariadb
