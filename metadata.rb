name             'mariadb'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs/Configures MariaDB'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/sous-chefs/mariadb'
issues_url       'https://github.com/sous-chefs/mariadb/issues'
chef_version     '>= 13'
version          '2.0.3'

supports 'ubuntu'
supports 'debian', '>= 8.0'
supports 'centos', '>= 6.4'

depends 'selinux_policy', '~> 2.0'
