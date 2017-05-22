# mariadb CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## 1.5.1 (2017-05-02)

### Fixed

- Remove check for chef-client running in local mode in the `galera` recipe which skips search - this prevents being able to search when using TK ([#160](https://github.com/sinfomicien/mariadb/pull/160))

## 1.5.0 (2017-04-25)

### Added

- Add the ability to set a custom wsrep_node_port, for when you want to specify a non default `wsrep_node_incoming_address` value ([#152](https://github.com/sinfomicien/mariadb/pull/152))

## 1.4.0 (2017-04-21)

### Fixed

- [#128](https://github.com/sinfomicien/mariadb/issues/128) solved, mysql-libs is prevented from being removed on newer CentOS versions causing Chef to break ([#153](https://github.com/sinfomicien/mariadb/pull/153))

### Changed

- `mariadb_replication` rewritten as a custom resource ([#151](https://github.com/sinfomicien/mariadb/pull/151))

### Removed

- Remove Fedora support, tested versions are long gone EOL and hard to support; only latest version has a repo on yum.mariadb.org

## 1.3.0 (2017-03-20)

### Added

- Add ability to enable and disable server audit logging ([#150](https://github.com/sinfomicien/mariadb/issues/150))

## 1.2.0 (2017-03-15)

### Added

- Add recipe and attributes to install using Software Collections (SCL) on RedHat family systems ([#149](https://github.com/sinfomicien/mariadb/issues/149))

## 1.1.0 (2017-03-12)

### Fixed

- Correctly set server-id and fixed replication provider `nil` string bug ([#118](https://github.com/sinfomicien/mariadb/issues/118))
- Make open-files-limit configurable (previously commented out in template) ([#118](https://github.com/sinfomicien/mariadb/issues/118))
- Fix package name for RedHat family distros using MariaDB 10.1 ([#138](https://github.com/sinfomicien/mariadb/issues/138))

### Added

- Add ability to specify your own `gcomm://` address for Galera replication ([#139](https://github.com/sinfomicien/mariadb/issues/139))
- Add attribute containing `my.cnf` sections to configure to allow users to override what cookbook manages
- Add attributes to configure general and slow log options ([#137](https://github.com/sinfomicien/mariadb/issues/137))
- Add Docker CI tests (add new APT key to fix [#107](https://github.com/sinfomicien/mariadb/issues/107), add Supermarket version badge and change Travis badge to show master build status to README)
- Add Docker tests to Travis for smoke tests

### Changed

- Change CHANGELOG format to follow [Keep a Changelog (v0.3.0)](http://keepachangelog.com/en/0.3.0/)
- Change `Chef search results` message log level to `debug` to remove unnecessary output ([#90](https://github.com/sinfomicien/mariadb/issues/90))
- Update Vagrant box names to match latest OS versions for testing with VirtualBox

### Removed

- Remove Fedora platfrom from Test-Kitchen, not something we'll test on going forward
- Remove Ubuntu 12.04 LTS from Test-Kitchen, not something we'll test on going forward as it reaches EOL in one month

## 1.0.1

### Fixed

- Correct ServerSpec tests
- Correct some Units tests (Use ServerRunner instead of SoloRunner to test search)

### Added

- Add an option to not install extra packages
- Update OS version to check with Kitchen

## 1.0.0

### Fixed

- Fix fetching apt key on every run bug ([#91](https://github.com/sinfomicien/mariadb/issues/91))
- Fix Foodcritic and RuboCop offences
- Fix ChefSpec tests (and adding more coverage)
- Fix some typos
- Fix CI
- Fix non-interpolated array
- Fix only_if
- Fix unary operator; ensure script exits on any error
- Prevent cookbook from crashing Chef < 12

### Added

- Add support for configuring skip-name-resolve
- Add missing code to my.cnf template to deploy mysqld_safe options
- Add the ability to config skip-log-bin to be present
- Add MariaDB 10.1 and data bag support
- Add exception handling, when searching for data bag
- Add some mandatory attributes and minor fixes
- Add test for bin_log unset
- Add sensitive tag to execute statement
- Add support to disable binlog (by setting `log_bin` to `false`)

### Changed

- Apply a more standard .gitignore
- Update chef components to more recent versions
- Update documentation for 'options' hash
- Use Berkshelf 4.x and RVM 2.1.7

### Removed

- Remove anonymous users and test database by default

## 0.3.3

### Added

- Add the ability to configure `skip-log-bin` to be present ([#110](https://github.com/sinfomicien/mariadb/issues/110))

## 0.3.2

### Fixed

- Add missing code to `my.cnf` template to deploy `mysqld_safe` options ([#125](https://github.com/sinfomicien/mariadb/issues/125))

### Added

- Add support for configuring skip-name-resolve ([#126](https://github.com/sinfomicien/mariadb/issues/126))

## 0.3.1

### Fixed

- Add user and password to correct debian-grants ([#57](https://github.com/sinfomicien/mariadb/issues/57))
- Correct service name inconsistency on CentOS 7 ([#68](https://github.com/sinfomicien/mariadb/issues/68))
- Fix directory permissions regression ([#73](https://github.com/sinfomicien/mariadb/issues/73))
- `mariadb_configuration` template uses current cookbook as template source ([#66](https://github.com/sinfomicien/mariadb/issues/66))
- Service is restarted every run if not localhost ([#76](https://github.com/sinfomicien/mariadb/issues/76))

### Added

- Add Scientific Linux support ([#69](https://github.com/sinfomicien/mariadb/issues/69))
- Add a vagrant config to test a Galera cluster ([#64](https://github.com/sinfomicien/mariadb/issues/64))
- Add xtrabackup-v2 support for SST Method ([#71](https://github.com/sinfomicien/mariadb/issues/71))
- Allow Galera cluster nodes to be configured when using Chef Solo ([#62](https://github.com/sinfomicien/mariadb/issues/62))

## 0.3.0

### Added

- Add support for using operating system shipped mariadb packages

## 0.2.12

### Fixed

- Push gpg key adds through http/0 - Helps with firewalled installs ([#39](https://github.com/sinfomicien/mariadb/issues/39))
- Load the needed plugins at startup ([#48](https://github.com/sinfomicien/mariadb/issues/48))

### Added

- Add cookbook attribute on configuration LWRP ([#46](https://github.com/sinfomicien/mariadb/issues/46))
- Allow to pass true for unary options ([#47](https://github.com/sinfomicien/mariadb/issues/47))

## 0.2.11

### Fixed

- Fix TypeError in the replication provider ([#43](https://github.com/sinfomicien/mariadb/issues/43))

### Added

- Add CentOS support ([#38](https://github.com/sinfomicien/mariadb/issues/38))
- Add sensitive flag to resource that deal with passwords ([#40](https://github.com/sinfomicien/mariadb/issues/40))

## 0.2.10

### Fixed

- Audit Plugin test and installation - Correct bad notifies and stdout test

## 0.2.9

### Fixed

- Audit plugin installation can crash mariadb server ([#36](https://github.com/sinfomicien/mariadb/issues/36))

## 0.2.8

### Fixed

- Add a switch to not launch audit plugin install, when already installed ([#29](https://github.com/sinfomicien/mariadb/issues/29))
- Remove the `only_if` to mysql service ([#28](https://github.com/sinfomicien/mariadb/issues/28))
- When using Galera, nodes were not sorted, applying configuration change too often ([#30](https://github.com/sinfomicien/mariadb/issues/30))

### Added

- Add more ChefSpec coverage ([#31](https://github.com/sinfomicien/mariadb/issues/31))
- Add a switch to separate server install and audit install when needed
- Add a RuboCop rule to allow line length to be 120 characters long

## 0.2.7

### Fixed

- Fix convert TypeError in the replication provider ([#24](https://github.com/sinfomicien/mariadb/issues/24))
- Data is now moved when `['mariadb']['mysqld']['datadir']` is changed ([#25](https://github.com/sinfomicien/mariadb/issues/25))

### Added

- Add `audit_plugin` management ([#31](https://github.com/sinfomicien/mariadb/issues/31))

## 0.2.6

### Fixed

- Fix provider `mariadb_replication` compilation error ([#18](https://github.com/sinfomicien/mariadb/issues/18))

### Added

- Complete CHANGELOG and correct README

## 0.2.5

### Fixed

- Fix the debian-sys-maint user creation/password change ([#12](https://github.com/sinfomicien/mariadb/issues/12))
- Fix the Galera root password preseed ([#11](https://github.com/sinfomicien/mariadb/issues/11))

### Added

- Add a LWRP to manage replication slave ([#16](https://github.com/sinfomicien/mariadb/issues/16))
- Add attribute to set custom `apt_repository`'s' `base_url` ([#6](https://github.com/sinfomicien/mariadb/issues/6))
- Add new tests for the new features (Galera, development files install, replication LWRP)
- Add option to skip installing development files within client recipe ([#17](https://github.com/sinfomicien/mariadb/issues/17))
- Add CHANGELOG and add new feature explanations to README

## 0.2.4

### Fixed

- Fix FC004 broken rule ([#10](https://github.com/sinfomicien/mariadb/issues/10))
- Fix Foodcritic tests (add --epic-fail any to be sure it fails when a broken rule is detected) ([#9](https://github.com/sinfomicien/mariadb/issues/9))

## 0.2.3

### Fixed

- Fix management of the mysql root password ([#4](https://github.com/sinfomicien/mariadb/issues/4))

### Added

- Add a lot of ChefSpec and kitchen/ServerSpec tests
- Add ability to add or remove root remote access via attribute ([#7](https://github.com/sinfomicien/mariadb/issues/7))
- Add immediate restart of the `mysql` service when port is changed ([#5](https://github.com/sinfomicien/mariadb/issues/5))
- Add more documentation

## 0.2.2

### Fixed

- Fix and add multiple tests
- Fix client install to add dev files
- Fix repository install under Debian family

## 0.2.1

### Added

- Add stove to package/publish cookbook (remove PaxHeaders)

## 0.2.0

### Fixed

- Correct the Documentation

### Added

- Add a recipe to manage client only installation
- Add RPM/Yum management

### Changed

- Refactor all tests to manage new platform (CentOS/RedHat/Fedora)
- Refactor the whole recipes list and management to ease it
- Rename the provider (from `extraconf` to `configuration`) and add matchers for it

## 0.1.8

### Added

- Add ignore-failure to debian-grants correct as it can break on initial setup

## 0.1.7

### Fixed

- Correct a typo (unnecessary call to `run_command`)

## 0.1.6

### Added

- Add new rspec tests
- Create Kitchen test suite
- Improve Galera configuration management

## 0.1.5

### Added

- Improve attributes management

## 0.1.4

### Added

- Adapt `galera55` recipe to use a generic galera recipe
- Improve documentation
- Use a generic Galera recipe to create the galera10 recipe

## 0.1.0

- Initial release of mariadb
