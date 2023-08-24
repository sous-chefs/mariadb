# mariadb_server_install

This resource installs mariadb server packages.

## Actions

- `install` - (default) Install server packages
- `create`  - Start the service, change the user root password

## Properties

Name                            | Types             | Description                                                   | Default                                   | Required?
------------------------------- | ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`version`                       | String            | Version of MariaDB to install                                 | `10.11`                                   | no
`setup_repo`                    | Boolean           | Define if you want to add the MariaDB repository              | `true`                                    | no
`password`                      | String, nil       | Pass in a password, or have the cookbook generate one for you | `generate`                                | no
`install_sleep`                 | Integer           | Number of seconds to sleep in between install commands        | `5`                                       | no
`package_action`                | :install, :upgrade| Package action behaviour                                      | `:install`                                | no

(1) `default_pid_file` is a helper method which return the pid file name and path based on OS flavor

## Examples

To install '10.3' version:

```ruby
mariadb_server_install 'MariaDB Server install' do
  version '10.3'
end
```
