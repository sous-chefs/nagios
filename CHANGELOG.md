## v1.2.6:

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
