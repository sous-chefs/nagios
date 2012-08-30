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
