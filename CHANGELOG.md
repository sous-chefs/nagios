## v4.1.4:

### Bug

- [COOK-3014]: Nagios cookbook imports data bag users even if they
  have action:remove

### Improvement

- [COOK-2826]: Allow Nagios cookbook to configure location of SSL
  files

## v4.1.2:

### Bug

- [COOK-2967]: nagios cookbook has foodcritic failure

### Improvement

- [COOK-2630]: Improvements to Readme and Services.cfg.erb template

### New Feature

- [COOK-2460]: create attribute for `allowed_hosts`

## v4.1.0:

* [COOK-2257] - Nagios incorrectly tries to use cloud IPs due to a OHAI bug
* [COOK-2474] - hosts.cfg.erb assumes if nagios server node has the
  cloud attributes all nodes have the cloud attributes
* [COOK-1068] - Nagios::client should support CentOS/RHEL NRPE
  installs via package
* [COOK-2565] - nginx don't send `AUTH_USER` & `REMOTE_USER` to nagios
* [COOK-2546] - nrpe config files should not be world readable
* [COOK-2558] - Services that are attached to hostgroups created from
  the nagios_hostgroups databag are not created
* [COOK-2612] - Nagios can't start if search can't find hosts defined
  in nagios_hostgroups
* [COOK-2473] - Install Nagios 3.4.4 for source installs
* [COOK-2541] - Nagios cookbook should use node.roles instead of
  node.run_list.roles when calculating hostgroups
* [COOK-2543] - Adds the ability to normalize hostnames to lowercase
* [COOK-2450] - Add ability to define service groups through data
  bags.
* [COOK-2642] - With multiple nagios servers, they can't use NRPE to
  check each other
* [COOK-2613] - Install Nagios 3.5.0 when installing from source

## v4.0.0:

This is a major release that refactors a significant amount of the
service configuration to use data bags rather than hardcoding specific
checks in the templates. The README describes how to create services
via data bags.

The main incompatibility and breaking change is that the default
services that are monitored by Nagios is reduced to only the
"check-nagios" service. This means that existing installations will
need to start converting checks over to the new data bag entries.

* [COOK-1553] - Nagios: check_nagios command does not work if Nagios
  is installed from source
* [COOK-1554] - Nagios: The nagios server should be added to all
  relevant host groups
* [COOK-1746] - nagios should provide more flexibility for server
  aliases
* [COOK-2006] - Extract default checks out of nagios
* [COOK-2129] - If a host is in the _default environment it should go
  into the _default hostgroup
* [COOK-2130] - Chef needs to use the correct nagios plugin path on
  64bit CentOS systems
* [COOK-2131] - gd development packages are not necessary for NRPE
  installs from source
* [COOK-2132] - Update NRPE installs to 2.14 from 2.13
* [COOK-2134] - Handle nagios-nrpe-server and nrpe names for NRPE in
  the init scripts and cookbook
* [COOK-2135] - Use with-nagios-user and group options source NRPE
  installs
* [COOK-2136] - Nagios will not pass config check when multiple
  machines in different domains have the same hostname
* [COOK-2150] - hostgroups data bag search doesn't respect the
  multi_environment_monitoring attribute
* [COOK-2186] - add service escalation to nagios
* [COOK-2188] - A notification interval of zero is valid but
  prohibited by the cookbook
* [COOK-2200] - Templates and Services from data bags don't specify
  intervals in the same way as the rest of the cookbook
* [COOK-2216] - Nagios cookbook readme needs improvement
* [COOK-2240] - Nagios server setup needs to gracefully fail when
  users data bag is not present
* [COOK-2241] - Stylesheets fail to load on a fresh Nagios install
* [COOK-2242] - Remove unused checks in the NRPE config file
* [COOK-2245] - nagios::server writes openid apache configs before
  including apache2::mod_auth_openid
* [COOK-2246] - Most of the commands in the Nagios cookbook don't work
* [COOK-2247] - nagios::client_source sets pkgs to a string, then
  tries to pkgs.each do {|pkg| package pkg }
* [COOK-2257] - Nagios incorrectly tries to use cloud IPs due to a
  OHAI bug
* [COOK-2275] - The Nagios3 download URL attribute is unused
* [COOK-2285] - Refactor data bag searches into library
* [COOK-2294] - Add cas authentication to nagios cookbook
* [COOK-2295] - nagios: chef tries to start nagios-nrpe-server on
  every run
* [COOK-2300] - You should be able to define a nagios_service into the
  "all" host group
* [COOK-2341] - pagerduty_nagios.pl URL changed
* [COOK-2350] - Nagios server fails to start when installed via source
  on Ubuntu/Debian
* [COOK-2369] - Add LDAP support in the nagios cookbook.
* [COOK-2374] - Setting an unmanaged host to a string returns 'no
  method error'
* [COOK-2375] - Allows adding a service that utilizes a pre-existing
  command
* [COOK-2433] - Nagios: ldap authentication needs to handle anonymous
  binding ldap servers

## v3.1.0:

* [COOK-2032] - Use public IP address for inter-cloud checks and
  private for intra-cloud checks
* [COOK-2081] - add support for `notes_url` to `nagios_services` data
  bags

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
