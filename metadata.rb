name 'mariadb'
maintainer 'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license 'Apache-2.0'
description 'Installs/Configures MariaDB'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/sous-chefs/mariadb' if respond_to?(:source_url)
issues_url 'https://github.com/sous-chefs/mariadb/issues' if respond_to?(:issues_url)
chef_version '>= 12.6' if respond_to?(:chef_version)
version '1.5.3'

supports 'ubuntu'
supports 'debian', '>= 7.0'
supports 'centos', '>= 6.4'
supports 'redhat', '>= 7.0'

depends 'apt'
depends 'build-essential'
depends 'selinux_policy', '~> 2.0'
depends 'yum'
depends 'yum-epel'
depends 'yum-scl'
