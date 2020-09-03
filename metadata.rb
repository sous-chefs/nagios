name             'nagios'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs and configures Nagios server'
version          '8.2.1'
issues_url       'https://github.com/sous-chefs/nagios/issues'
source_url       'https://github.com/sous-chefs/nagios'
chef_version     '>= 14'

depends 'apache2', '< 6.0' # 6.0+ removes all recipes and attributes
depends 'nginx', '>= 7.0'
depends 'php-fpm', '>= 0.7.9'
depends 'zap', '>= 0.6.0'

%w(php yum-epel nrpe).each do |cb|
  depends cb
end

%w(centos oracle redhat).each do |os|
  supports os, '>= 7.0'
end

supports 'debian', '>= 8.0'
supports 'ubuntu', '>= 14.04'
