# mariadb_configuration

Mainly use for internal purpose. You can use it to create a new configuration file into configuration dir. You have to define 2 variables `section` and `option`.
Where `section` is the configuration section, and `option` is a hash of key/value. The name of the resource is used as base for the filename.

## Actions

- `add` - (default) Install the extra configuration file
- `remove`  - Remove the extra configuration file

## Properties

Name                | Types             | Description                                                   | Default                                   | Required?
------------------- | ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`configuration_name`| String            | Name of the extra conf file, used for .cnf filename           |                                           | yes
`section`           | String            |                                                               |                                           | yes
`option`            | Hash              | All option to write in the configuration file                 | `{}`                                      | yes
`cookbook`          | String            | The cookbook to look in for the template source               | `'mariadb`                                | yes
`extconf_directory` | String            | An additional directory from which Mysql read extra cnf       | `"ext_conf_dir` (1)                       | yes

(1) `ext_conf_dir` is a helper method which return the extra configuration directory based on OS flavor

## Examples

This example:

```ruby
mariadb_configuration 'fake' do
  section 'mysqld'
  option :foo => 'bar'
end
```

will become the file fake.cnf in the include dir (depend on your platform), which contain:

```
[mysqld]
foo=bar
```

In another example, if the value start with a '#', then it's considered as a comment, and the value is printed as is (without the key):

```ruby
mariadb_configuration 'fake' do
  section 'mysqld'
  option :comment1 => '# Here i am',
    :foo => bar
end
```

will become the file fake.cnf in the include dir (depend on your platform), which contain:

```
[mysqld]
# Here i am
foo=bar
```
