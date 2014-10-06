mariadb CHANGELOG
=================

This file is used to list changes made in each version of the mariadb cookbook.
0.2.6
-----
- [DOCS] - Complete Changelog, and correct README

0.2.5
-----
- [ENH #16] - Add a LWRP to manage replication slave
- [ENH #17] - Be able to not install development files within client recipe
- [ENH #11] - Fix the galera root password preseed
- [BUG #12] - Fix the debian-sys-maint user creation/password change
- [BUG #6] - Can change the apt repository base_url when the default one fail
- [TEST] - Add new tests for the new features (galera,development files install,replication LWRP)
- [DOCS] - Complete Changelog, and add new features explanations into README

0.2.4
-----
- [BUG #10] - Correct a FC004 broken rule
- [BUG #9] - Correct foodcritic tests (add --epic-fail any to be sure it fails when a broken rule is detected)

0.2.3
-----
- [BUG #4] - Add a real management of mysql root password
- [ENH #5] - Now restart mysql service when port is changed
- [ENH #7] - Remove or add root remote access via attribute
- [DOCS] - Complete documentations
- [TEST] - Add a lot of chefspec and kitchen/serverspec tests

0.2.2
-----
- [sinfomicien] - Correct repository install under debian family
- [sinfomicien] - Correct client install to add dev files
- [sinfomicien] - Correct and add multiples tests

0.2.1
-----
- [sinfomicien] - Use stove to package (remove PaxHeaders.*)

0.2.0
-----
- [sinfomicien] -  Add rpm/yum management
- [sinfomicien] -  Refactor the whole recipes list and management to ease it
- [sinfomicien] -  Correct the Documentation
- [sinfomicien] -  Rename the provider (from extraconf to configuration), and add matchers to it
- [sinfomicien] -  Add a recipe to manage client only installation
- [sinfomicien] -  Refactor all tests to manage new platform (centos/redhat/fedora)

0.1.8
-----
- [sinfomicien] -  Add ignore-failure to debian grants correct, as it can break on initial setup

0.1.7
-----
- [sinfomicien] -  Correct a typo (unnecessary call to run_command)

0.1.6
-----
- [sinfomicien] -  improve Galera configuration management
- [sinfomicien] -  Add new rspec tests
- [sinfomicien] -  Create Kitchen test suite

0.1.5
-----
- [sinfomicien] -  improve attributes management

0.1.4
-----
- [sinfomicien] - adapt galera55 recipe to use a generic galera recipe
- [sinfomicien] - use a generic galera recipe to create the galera10 recipe
- [sinfomicien] - Improve documentation 


0.1.0
-----
- [sinfomicien] - Initial release of mariadb
