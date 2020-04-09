name             'nagios'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs and configures Nagios server'
version          '9.0.0'
issues_url       'https://github.com/sous-chefs/nagios/issues'
source_url       'https://github.com/sous-chefs/nagios'
chef_version     '>= 14'

depends 'apache2' '>= 8.0'
depends 'nginx', '>= 10.2'
depends 'nrpe'
depends 'php', '>= 4.0.0'
depends 'yum-epel'
depends 'zap', '>= 0.6.0'

%w(centos oracle redhat).each do |os|
  supports os, '>= 7.0'
end

supports 'debian', '>= 10.0'
supports 'ubuntu', '>= 16.04'
