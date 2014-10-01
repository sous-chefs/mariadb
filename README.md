MariaDB Cookbook
================

[![Build Status](https://travis-ci.org/sinfomicien/mariadb.png)](https://travis-ci.org/sinfomicien/mariadb)

Description
-----------

This cookbook contains all the stuffs to install and configure a mariadb server on a dpkg/apt compliant system (typically debian), or a rpm/yum compliant system (typically centos)


Requirements
------------

#### repository
- `mariadb` - This cookbook need that you have a valid apt repository installed with the mariadb official packages

#### packages
- `percona-xtrabackup` - if you want to use the xtrabckup SST Auth for galera cluster.
- `socat` - if you want to use the xtrabckup SST Auth for galera cluster.
- `rsync` - if you want to use the rsync SST Auth for galera cluster.
- `debconf-utils` - if you use debian platform family.

#### operating system
- `debian` - this cookbook is fully tested on debian
- `ubuntu` - not fully tested on ubuntu, but should work
- `centos` - not fully tested on centos, but should work

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
    <td><tt>['mariadb']['install']['version']</tt></td>
    <td>String</td>
    <td>Version to install (currently 10.0 et 5.5)</td>
    <td><tt>10.0</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['use_default_repository']</tt></td>
    <td>Boolean</td>
    <td>Wether to install MariaDB default repository or not. If you don't have a local repo containing packages, put it to true</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['server_root_password']</tt></td>
    <td>String</td>
    <td>local root password</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['forbid_remote_root']</tt></td>
    <td>Boolean</td>
    <td>Wether to activate root remote access</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['allow_root_pass_change']</tt></td>
    <td>Boolean</td>
    <td>Wether to allow the recipe to change root password after the first install</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['client']['development_files']</tt></td>
    <td>Boolean</td>
    <td>Wether to install development files in client recipe</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['mariadb']['apt_repository']['base_url']</tt></td>
    <td>String</td>
    <td>The http base url to use when installing from default repository</td>
    <td><tt>'ftp.igh.cnrs.fr/pub/mariadb/repo'</tt></td>
  </tr>
</table>

Usage
-----

To install a default server for mariadb choose the version you want (MariaDB 5.5 or 10, galera or not), then call the recipe accordingly.

List of availables recipes:

- mariadb::default (just call server recipe with default options)
- mariadb::server
- mariadb::galera
- mariadb::client

Please be ware that by default, the root password is empty! If you want have changed it use the `node['mariadb']['server_root_password']` attribute to put a correct value. And by default the remote root access is not activated. Use `node['mariadb']['forbid_remote_root']` attribute to change it.

Sometimes, the default apt repository used for apt does not work (see issue #6). In this case, you need to choose another mirror which worki (pick it from mariadb website), and put the http base url in the attribute `node['mariadb']['apt_repository']['base_url']`.

#### mariadb::galera

When installing the mariadb::galera on debian recipe, You have to take care of one specific attribute:
`node['mariadb']['debian']['password']` which default to 'please-change-me'
As wee need to have the same password for this user on the whole cluster nodes... We will change the default install one by the content of this attribute.

#### mariadb::client

By default this recipe install the client, and all needed packages to develop client application. If you do not want to install development files when installing client package,
set the attribute `node['mariadb']['client']['development_files']` to false. 

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
