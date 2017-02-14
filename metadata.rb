name              'nagios'
maintainer        'Tim Smith'
maintainer_email  'tsmith@chef.io'
license           'Apache 2.0'
description       'Installs and configures Nagios server'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '7.2.7'
issues_url       'https://github.com/schubergphilis/nagios/issues'
source_url       'https://github.com/schubergphilis/nagios'
chef_version     '>= 12.1' if respond_to?(:chef_version)

recipe 'default', 'Installs Nagios server.'
recipe 'nagios::pagerduty', 'Integrates contacts w/ PagerDuty API'

depends 'apache2', '>= 2.0'
depends 'zap', '>= 0.6.0'

%w( build-essential php chef_nginx nginx_simplecgi yum-epel nrpe ).each do |cb|
  depends cb
end

%w( debian ubuntu redhat centos fedora scientific amazon oracle).each do |os|
  supports os
end
