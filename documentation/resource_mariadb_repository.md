# mariadb_repository

It installs the mariadb.org apt or yum repository

## Actions

- `install` - (default) Install mariadb.org apt or yum repository

## Properties

Name                | Types             | Description                                                   | Default                                      | Required?
------------------- | ----------------- | ------------------------------------------------------------- | -------------------------------------------- | ---------
`version`           | String            | Version of MariaDB to install                                 | `10.3`                                       | no
`apt_gpg_keyserver` | String            | The key server url in which grab the gpg key                  | `keyserver.ubuntu.com`                       | no
`apt_repository_uri`| String            | The repository url                                            | `http://mariadb.mirrors.ovh.net/MariaDB/repo`| no

## Examples

To install '10.3' version:

```ruby
mariadb_repository 'MariaDB 10.3 Repository' do
  version '10.3'
end
```
