# mariadb_server_install

This resource installs mariadb server packages.

## Actions

- `install` - (default) Install server packages
- `create`  - Start the service, change the user root password

## Properties

Name                            | Types             | Description                                                   | Default                                   | Required?
------------------------------- | ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`version`                       | String            | Version of MariaDB to install                                 | `10.3`                                    | no
`setup_repo`                    | Boolean           | Define if you want to add the MariaDB repository              | `true`                                    | no
`mycnf_file`                    | String            |                                                               | `"#{conf_dir}/my.cnf"` (1)                | no
`extra_configuration_directory` | String            |                                                               | `ext_conf_dir` (2)                        | no
`external_pid_file`             | String            |                                                               | `default_pid_file` (3)                    | no
`cookbook`                      | String            | The cookbook to look in for the template source               | `mariadb`                                 | yes
`password`                      | String, nil       | Pass in a password, or have the cookbook generate one for you | `generate`                                | no

(1) `conf_dir` is a helper method which return the main configuration directory based on OS flavor
(2) `ext_conf_dir` is a helper method which return the extra configuration directory based on OS flavor
(3) `default_pid_file` is a helper method which return the pid file name and path based on OS flavor

## Examples

To install '10.3' version:

```ruby
mariadb_server_install 'MariaDB Server install' do
  version '10.3'
end
```
