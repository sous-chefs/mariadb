# mariadb_client_install

This resource installs mariadb client packages.

## Actions

- `install` - (default) Install client packages

## Properties

Name                | Types             | Description                                                   | Default                                   | Required?
------------------- | ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`version`           | String            | Version of MariaDB to install                                 | `10.11`                                   | no
`setup_repo`        | Boolean           | Define if you want to add the MariaDB repository              | `true`                                    | no
`package_action`    | :install, :upgrade| Package action behaviour                                      | `:install`                                | no

### Examples

To install '10.3' version:

```ruby
mariadb_client_install 'MariaDB Client install' do
  version '10.3'
end
```
