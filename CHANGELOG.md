## v3.0.0:

This is a major release due to some dramatic refactoring to the
service check configuration which may not be compatible with existing
implementations of this cookbook.

* [COOK-1544] - Nagios cookbook needs to support event handlers
* [COOK-1785] - Template causes service restart every time
* [COOK-1879] - Nagios: add configuration to automatically redirect
  http://myserver/ to http://myserver/nagios3/
* [COOK-1880] - Extra attribute was left over after the
  `multi_environment_monitoring` update
* [COOK-1881] - Oracle should be added to the metadata for Nagios
* [COOK-1891] - README says to modify the nrpe.cfg template, but the
  cookbook exports a resource for nrpe checks.
* [COOK-1947] - Nagios: Pager duty portions of Nagios cookbook not
  using nagios user/group attributes
* [COOK-1949] - Nagios: A bad role on a node shouldn't cause the
  cookbook to fail
* [COOK-1950] - Nagios: Simplify hostgroup building and cookbook code
* [COOK-1995] - Nagios: Update source install to use Nagios 3.4.3 not
  3.4.1
* [COOK-2005] - Remove unusable check commands from nagios
* [COOK-2031] - Adding templates as a data bag, extending service data
  bag to take arbitrary config items
* [COOK-2032] - Use public IP address for intra-cloud checks
* [COOK-2034] - Nagios cookbook calls search more often than necessary
* [COOK-2054] - Use service description in the nagios_services databag
  items
* [COOK-2061] - template.erb refers to a service variable when it
  should reference template.

## v2.0.0:

* [COOK-1543] - Nagios cookbook needs to be able to monitor environments
* [COOK-1556] - Nagios: Add ability to define service template to be used in the
  `nagios_services` data bag
* [COOK-1618] - Users data bag group allowed to log into Nagios should
  be configurable
* [COOK-1696] - Nagios: Support defining non-Chef managed hosts via
  data bag items
* [COOK-1697] - nagios: Source installs should install the latest NRPE
  and Nagios plugins
* [COOK-1717] - Nagios: nagios server web page under Apache2 fails to
  load out of the box
* [COOK-1723] - Amazon missing as a supported OS in the Nagios metadata
* [COOK-1732] - `nagios::client_source` includes duplicate resources
* [COOK-1815] - Switch Nagios to use platform_family not platform
* [COOK-1816] - Nagios: mod ssl shouldn't get installed if SSL isn't being used
* [COOK-1887] - `value_for_platform_family` use in Nagios cookbook is
  broken

## v1.3.0:

* [COOK-715] - don't source /etc/sysconfig/network on non-RHEL
  platforms
* [COOK-769] - don't use nagios specific values in users data bag
  items if they don't exist
* [COOK-1206] - add nginx support
* [COOK-1225] - corrected inconsistencies (mode, user/group, template
  headers)
* [COOK-1281] - add support for amazon linux
* [COOK-1365] - nagios_conf does not use nagios user/group attributes
* [COOK-1410] - remvoe deprecated package resource
* [COOK-1411] - Nagios server source installs should not necessarily
  install the NRPE client from source
* [COOK-1412] - Nagios installs from source do not install a mail
  client so notifications fail
* [COOK-1413] - install nagios 3.4.1 instead of 3.2.3
* [COOK-1518] - missing sysadmins variable in apache recipe
* [COOK-1541] - support environments that have windows systems
* [COOK-1542] - allow setting flap detection via attribute
* [COOK-1545] - add support for defining host groups using search in
  data bags
* [COOK-1553] - check_nagios command doesn't work from source install
* [COOK-1555] - include service template for monitoring logs
* [COOK-1557] - check-nagios command only works in environments with
  single nagios server
* [COOK-1587] - use default attributes instead of normal in cookbook
  attributes files

## V1.2.6:

* [COOK-860] - set mail command with an attribute by platform

## v1.2.4:

* [COOK-1119] - attributes for command_timeout / dont_blame_nrpe options
* [COOK-1120] - allow monitoring from servers in multiple chef_environments

## v1.2.2:

* [COOK-991] - NRPE LWRP No Longer Requires a Template
* [COOK-955] - Nagios Service Checks Defined by Data Bags

## v1.2.0:

* [COOK-837] - Adding a Recipe for PagerDuty integration
* [COOK-868] - use node, not @node in template
* [COOK-869] - corrected NRPE PID path
* [COOK-907] - LWRP for defining NRPE checks
* [COOK-917] - changes to `mod_auth_openid` module

## v1.0.4:

* [COOK-838] - Add HTTPS Option to Nagios Cookbook

## v1.0.2:

* [COOK-636] - Nagios server recipe attempts to start too soon
* [COOK-815] - Nagios Config Changes Kill Nagios If Config Goes Bad

## v1.0.0:

* Use Chef 0.10's `node.chef_environment` instead of `node['app_environment']`.
* source installation support on both client and server sides
* initial RHEL/CentOS/Fedora support
