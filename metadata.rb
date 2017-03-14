name 'mariadb'
maintainer 'Nicolas Blanc'
maintainer_email 'sinfomicien@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures MariaDB'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/sinfomicien/mariadb' if respond_to?(:source_url)
issues_url 'https://github.com/sinfomicien/mariadb/issues' if respond_to?(:issues_url)
chef_version '>= 12.6' if respond_to?(:chef_version)
version '1.3.0'

supports 'ubuntu'
supports 'debian', '>= 7.0'
supports 'centos', '>= 6.4'
supports 'redhat', '>= 7.0'

depends 'build-essential'
depends 'apt'
depends 'yum'
depends 'yum-epel'
depends 'yum-scl'
depends 'selinux_policy'
