name 'mariadb'
maintainer 'Nicolas Blanc'
maintainer_email 'sinfomicien@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures MariaDB'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/sinfomicien/mariadb'
issues_url 'https://github.com/sinfomicien/mariadb/issues'
version '0.3.2'

supports 'ubuntu'
supports 'debian', '>= 7.0'
supports 'centos', '>= 6.4'
supports 'redhat', '>= 7.0'

depends 'apt'
depends 'yum'
depends 'yum-epel'
