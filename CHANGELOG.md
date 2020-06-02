# mariadb CHANGELOG

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/).

## 4.0.1 (2020-06-02)

- resolved cookstyle error: resources/repository.rb:60:18 refactor: `ChefCorrectness/InvalidPlatformFamilyInCase`

## 4.0.0 (2020-05-22)

- Update CHANGELOG format
- Add CentOS 8 to GitHub Actions
- Add Ubuntu 20.04 to GitHub Actions
- Remove Amazon Linux 2 from GitHub Actions
- Chef 15 is now the lowest supported version
  - See [cookbook support](https://sous-chefs.org/docs/cookbook-support/) for more information.

## 3.2.0 (2020-05-05)

- Simplify a platform version check in the repository resource and the helpers library
- Migrate testing to Github Actions
- Simplify the apt_repository resource usage in the repository resource
- Use true/false in the user resource not TrueClass / FalseClass
- Fixed changing the character set and collation of an existing database resource
- Simplify a platform version check in the repository resource
- Migrate testing to GitHub Actions
- Various Cookstyle fixes:
  - resolved cookstyle error: resources/server_configuration.rb:203:5 refactor: `ChefStyle/NegatingOnlyIf`
  - resolved cookstyle error: resources/server_configuration.rb:288:7 refactor: `ChefStyle/NegatingOnlyIf`
  - resolved cookstyle error: test/cookbooks/test/recipes/user_database.rb:1:16 warning: `Lint/SendWithMixinArgument`
  - resolved cookstyle error: resources/database.rb:24:42 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/database.rb:25:42 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/galera_configuration.rb:24:66 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/galera_configuration.rb:25:66 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/galera_configuration.rb:32:66 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/replication.rb:25:54 convention: `Layout/ExtraSpacing`
  - resolved cookstyle error: resources/replication.rb:25:56 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/replication.rb:26:71 convention: `Layout/ExtraSpacing`
  - resolved cookstyle error: resources/server_configuration.rb:27:62 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/server_configuration.rb:65:62 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`
  - resolved cookstyle error: resources/server_configuration.rb:93:62 refactor: `ChefRedundantCode/StringPropertyWithNilDefault`

## 3.1.0 (2019-10-24)

- Fix `mariadbbackup_pkg_name` helper for yum-based platforms ([#276](https://github.com/sous-chefs/mariadb/issues/276))
- Fix replication resource `load_current_value` to use Integers where required
- Fix Make `server_configuration` and `server_install` resources idempotent ([#265](https://github.com/sous-chefs/mariadb/issues/265))
- Simplify platform check logic in the repository resource

## 3.0.0 (2019-10-17)

- Added tests suite for 2 scenarios (`galera_configuration` and `port_changed`)
- Added support for Debian 10
- Update documentation following sous-chefs.org guidelines
- Fix undefined method `ext_conf_dir` when using mariadb 2.0.0 ([#225](https://github.com/sous-chefs/mariadb/issues/225))
- Fix Rename property `apt_repository` to `apt_repository_uri` in repository resource ([#245](https://github.com/sous-chefs/mariadb/issues/245))
- Fix markdown and yaml linting, cookstyle, and parallel circle builds
- Remove support for debian 8 (end of life since 2018-6-6)

## 2.1.0

- Add property `apt_key_proxy` to `mariadb_repository` to be able to pass a proxy setting to apt-key ([#234](https://github.com/sous-chefs/mariadb/pull/234/commits/d5b09122492d5474b38ad00a454bf49175a12c79))
- Add a mechanism to properly set the root password for mariadb ([#234-bc33fb2](https://github.com/sous-chefs/mariadb/pull/234/commits/bc33fb2c9dfc0a14754eb76bbff43ac6c3346d5b) : [#234-c576d42](https://github.com/sous-chefs/mariadb/pull/234/commits/c576d42a7317d63d87a0cff44ad7c564a9b1a0e2))
- Add APT repository property to allow the user to select another mirror than ovh.net
- Fix String quoting that prevented some SQL commands to execute properly ([#220](https://github.com/sous-chefs/mariadb/issues/220))
- Fix broken CHANGELOG links
- Fix setup repo condition, it always updated even if `setup_repo` was `false`

## 2.0.0

- Added all resources which replace the old recipes
- Removed support for fedora
- Removed all recipes
- Removed support for Chef 13

## 1.5.4 (2018-05-25)

- Added resource `mariadb_database` to manage databases ([#187](https://github.com/sous-chefs/mariadb/pull/187))
- Added resource `mariadb_user` to manage users and privileges ([#187](https://github.com/sous-chefs/mariadb/pull/187))
- Added support for MariaDB galera 10.2 ([#197](https://github.com/sous-chefs/mariadb/pull/197))
- Added support for Debian 9 ([#193](https://github.com/sous-chefs/mariadb/issues/193),[#194](https://github.com/sous-chefs/mariadb/issues/194),[#198](https://github.com/sous-chefs/mariadb/issues/198),[#202](https://github.com/sous-chefs/mariadb/issues/202))
- Added the new SST method mariabackup ([#192](https://github.com/sous-chefs/mariadb/issues/192))
- Fixed a libssl conflict when using resources based on mysql2 gem ([#193](https://github.com/sous-chefs/mariadb/pull/193))
- Fixed lack of libmariadbclient-dev on Ubuntu 16.04 when using native package ([#186](https://github.com/sous-chefs/mariadb/issues/186))
- Removed support for Chef 12 ([#203](https://github.com/sous-chefs/mariadb/issues/203))

## 1.5.3 (2017-10-13)

This cookbook was transferred to Sous Chefs.

- Fixed bug where cookbook tries to set root password on every run instead of first install only ([#174](https://github.com/sinfomicien/mariadb/issues/174))

## 1.5.2 (2017-10-05)

- Added optimisations for client and server ChefSpec ([#165](https://github.com/sinfomicien/mariadb/issues/165))
- Added support for Percona XtraBackup 2.4 package ([#170](https://github.com/sinfomicien/mariadb/issues/170))
- Fixed CookStyle warnings ([#172](https://github.com/sinfomicien/mariadb/issues/172))
- Fixed Chefspec/Fauxhai deprecation messages ([#171](https://github.com/sinfomicien/mariadb/issues/171))
- Fixed missing privileges on sstuser ([#168](https://github.com/sinfomicien/mariadb/pull/168))
- Ensure configuration reload and server start after config ([#166](https://github.com/sinfomicien/mariadb/pull/166))
- Removed some OSes from Travis test suite; now only running tests on latest supported OS releases to get faster feedback

## 1.5.1 (2017-05-02)

- Remove check for chef-client running in local mode in the `galera` recipe which skips search - this prevents being able to search when using TK ([#160](https://github.com/sinfomicien/mariadb/pull/160))

## 1.5.0 (2017-04-25)

- Add the ability to set a custom wsrep_node_port, for when you want to specify a non default `wsrep_node_incoming_address` value ([#152](https://github.com/sinfomicien/mariadb/pull/152))

## 1.4.0 (2017-04-21)

- [#128](https://github.com/sinfomicien/mariadb/issues/128) solved, mysql-libs is prevented from being removed on newer CentOS versions causing Chef to break ([#153](https://github.com/sinfomicien/mariadb/pull/153))
- `mariadb_replication` rewritten as a custom resource ([#151](https://github.com/sinfomicien/mariadb/pull/151))
- Remove Fedora support, tested versions are long gone EOL and hard to support; only latest version has a repo on yum.mariadb.org

## 1.3.0 (2017-03-20)

- Add ability to enable and disable server audit logging ([#150](https://github.com/sinfomicien/mariadb/issues/150))

## 1.2.0 (2017-03-15)

- Add recipe and attributes to install using Software Collections (SCL) on RedHat family systems ([#149](https://github.com/sinfomicien/mariadb/issues/149))

## 1.1.0 (2017-03-12)

- Correctly set server-id and fixed replication provider `nil` string bug ([#118](https://github.com/sinfomicien/mariadb/issues/118))
- Make open-files-limit configurable (previously commented out in template) ([#118](https://github.com/sinfomicien/mariadb/issues/118))
- Fix package name for RedHat family distros using MariaDB 10.1 ([#138](https://github.com/sinfomicien/mariadb/issues/138))
- Add ability to specify your own `gcomm://` address for Galera replication ([#139](https://github.com/sinfomicien/mariadb/issues/139))
- Add attribute containing `my.cnf` sections to configure to allow users to override what cookbook manages
- Add attributes to configure general and slow log options ([#137](https://github.com/sinfomicien/mariadb/issues/137))
- Add Docker CI tests (add new APT key to fix [#107](https://github.com/sinfomicien/mariadb/issues/107), add Supermarket version badge and change Travis badge to show master build status to README)
- Add Docker tests to Travis for smoke tests
- Change CHANGELOG format to follow [Keep a Changelog (v0.3.0)](http://keepachangelog.com/en/0.3.0/)
- Change `Chef search results` message log level to `debug` to remove unnecessary output ([#90](https://github.com/sinfomicien/mariadb/issues/90))
- Update Vagrant box names to match latest OS versions for testing with VirtualBox
- Remove Fedora platfrom from Test-Kitchen, not something we'll test on going forward
- Remove Ubuntu 12.04 LTS from Test-Kitchen, not something we'll test on going forward as it reaches EOL in one month

## 1.0.1

- Correct ServerSpec tests
- Correct some Units tests (Use ServerRunner instead of SoloRunner to test search)
- Add an option to not install extra packages
- Update OS version to check with Kitchen

## 1.0.0

- Fix fetching apt key on every run bug ([#91](https://github.com/sinfomicien/mariadb/issues/91))
- Fix Foodcritic and RuboCop offences
- Fix ChefSpec tests (and adding more coverage)
- Fix some typos
- Fix CI
- Fix non-interpolated array
- Fix only_if
- Fix unary operator; ensure script exits on any error
- Prevent cookbook from crashing Chef < 12
- Add support for configuring skip-name-resolve
- Add missing code to my.cnf template to deploy mysqld_safe options
- Add the ability to config skip-log-bin to be present
- Add MariaDB 10.1 and data bag support
- Add exception handling, when searching for data bag
- Add some mandatory attributes and minor fixes
- Add test for bin_log unset
- Add sensitive tag to execute statement
- Add support to disable binlog (by setting `log_bin` to `false`)
- Apply a more standard .gitignore
- Update chef components to more recent versions
- Update documentation for 'options' hash
- Use Berkshelf 4.x and RVM 2.1.7
- Remove anonymous users and test database by default

## 0.3.3

- Add the ability to configure `skip-log-bin` to be present ([#110](https://github.com/sinfomicien/mariadb/issues/110))

## 0.3.2

- Add missing code to `my.cnf` template to deploy `mysqld_safe` options ([#125](https://github.com/sinfomicien/mariadb/issues/125))
- Add support for configuring skip-name-resolve ([#126](https://github.com/sinfomicien/mariadb/issues/126))

## 0.3.1

- Add user and password to correct debian-grants ([#57](https://github.com/sinfomicien/mariadb/issues/57))
- Correct service name inconsistency on CentOS 7 ([#68](https://github.com/sinfomicien/mariadb/issues/68))
- Fix directory permissions regression ([#73](https://github.com/sinfomicien/mariadb/issues/73))
- `mariadb_configuration` template uses current cookbook as template source ([#66](https://github.com/sinfomicien/mariadb/issues/66))
- Service is restarted every run if not localhost ([#76](https://github.com/sinfomicien/mariadb/issues/76))
- Add Scientific Linux support ([#69](https://github.com/sinfomicien/mariadb/issues/69))
- Add a vagrant config to test a Galera cluster ([#64](https://github.com/sinfomicien/mariadb/issues/64))
- Add xtrabackup-v2 support for SST Method ([#71](https://github.com/sinfomicien/mariadb/issues/71))
- Allow Galera cluster nodes to be configured when using Chef Solo ([#62](https://github.com/sinfomicien/mariadb/issues/62))

## 0.3.0

- Add support for using operating system shipped mariadb packages

## 0.2.12

- Push gpg key adds through http/0 - Helps with firewalled installs ([#39](https://github.com/sinfomicien/mariadb/issues/39))
- Load the needed plugins at startup ([#48](https://github.com/sinfomicien/mariadb/issues/48))
- Add cookbook attribute on configuration LWRP ([#46](https://github.com/sinfomicien/mariadb/issues/46))
- Allow to pass true for unary options ([#47](https://github.com/sinfomicien/mariadb/issues/47))

## 0.2.11

- Fix TypeError in the replication provider ([#43](https://github.com/sinfomicien/mariadb/issues/43))
- Add CentOS support ([#38](https://github.com/sinfomicien/mariadb/issues/38))
- Add sensitive flag to resource that deal with passwords ([#40](https://github.com/sinfomicien/mariadb/issues/40))

## 0.2.10

- Audit Plugin test and installation - Correct bad notifies and stdout test

## 0.2.9

- Audit plugin installation can crash mariadb server ([#36](https://github.com/sinfomicien/mariadb/issues/36))

## 0.2.8

- Add a switch to not launch audit plugin install, when already installed ([#29](https://github.com/sinfomicien/mariadb/issues/29))
- Remove the `only_if` to mysql service ([#28](https://github.com/sinfomicien/mariadb/issues/28))
- When using Galera, nodes were not sorted, applying configuration change too often ([#30](https://github.com/sinfomicien/mariadb/issues/30))
- Add more ChefSpec coverage ([#31](https://github.com/sinfomicien/mariadb/issues/31))
- Add a switch to separate server install and audit install when needed
- Add a RuboCop rule to allow line length to be 120 characters long

## 0.2.7

- Fix convert TypeError in the replication provider ([#24](https://github.com/sinfomicien/mariadb/issues/24))
- Data is now moved when `['mariadb']['mysqld']['datadir']` is changed ([#25](https://github.com/sinfomicien/mariadb/issues/25))
- Add `audit_plugin` management ([#31](https://github.com/sinfomicien/mariadb/issues/31))

## 0.2.6

- Fix provider `mariadb_replication` compilation error ([#18](https://github.com/sinfomicien/mariadb/issues/18))
- Complete CHANGELOG and correct README

## 0.2.5

- Fix the debian-sys-maint user creation/password change ([#12](https://github.com/sinfomicien/mariadb/issues/12))
- Fix the Galera root password preseed ([#11](https://github.com/sinfomicien/mariadb/issues/11))
- Add a LWRP to manage replication slave ([#16](https://github.com/sinfomicien/mariadb/issues/16))
- Add attribute to set custom `apt_repository`'s' `base_url` ([#6](https://github.com/sinfomicien/mariadb/issues/6))
- Add new tests for the new features (Galera, development files install, replication LWRP)
- Add option to skip installing development files within client recipe ([#17](https://github.com/sinfomicien/mariadb/issues/17))
- Add CHANGELOG and add new feature explanations to README

## 0.2.4

- Fix FC004 broken rule ([#10](https://github.com/sinfomicien/mariadb/issues/10))
- Fix Foodcritic tests (add --epic-fail any to be sure it fails when a broken rule is detected) ([#9](https://github.com/sinfomicien/mariadb/issues/9))

## 0.2.3

- Fix management of the mysql root password ([#4](https://github.com/sinfomicien/mariadb/issues/4))
- Add a lot of ChefSpec and kitchen/ServerSpec tests
- Add ability to add or remove root remote access via attribute ([#7](https://github.com/sinfomicien/mariadb/issues/7))
- Add immediate restart of the `mysql` service when port is changed ([#5](https://github.com/sinfomicien/mariadb/issues/5))
- Add more documentation

## 0.2.2

- Fix and add multiple tests
- Fix client install to add dev files
- Fix repository install under Debian family

## 0.2.1

- Add stove to package/publish cookbook (remove PaxHeaders)

## 0.2.0

- Correct the Documentation
- Add a recipe to manage client only installation
- Add RPM/Yum management
- Refactor all tests to manage new platform (CentOS/RedHat/Fedora)
- Refactor the whole recipes list and management to ease it
- Rename the provider (from `extraconf` to `configuration`) and add matchers for it

## 0.1.8

- Add ignore-failure to debian-grants correct as it can break on initial setup

## 0.1.7

- Correct a typo (unnecessary call to `run_command`)

## 0.1.6

- Add new rspec tests
- Create Kitchen test suite
- Improve Galera configuration management

## 0.1.5

- Improve attributes management

## 0.1.4

- Adapt `galera55` recipe to use a generic galera recipe
- Improve documentation
- Use a generic Galera recipe to create the galera10 recipe

## 0.1.0

- Initial release of mariadb
