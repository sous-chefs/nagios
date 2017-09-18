# nagios cookbook

[![Build Status](https://travis-ci.org/sous-chefs/nagios.svg)](https://travis-ci.org/sous-chefs/nagios) [![Cookbook Version](https://img.shields.io/cookbook/v/nagios.svg)](https://supermarket.chef.io/cookbooks/nagios)

Installs and configures Nagios server. Chef nodes are automatically discovered using search, and Nagios host groups are created based on Chef roles and optionally environments as well.

## Requirements

### Chef

Chef version 12.9+ is required

Because of the heavy use of search, this recipe will not work with Chef Solo, as it cannot do any searches without a server.

This cookbook relies heavily on multiple data bags. See **Data Bag** below.

The system running this cookbooks should have a role named 'monitoring' so that NRPE clients can authorize monitoring from that system. This role name is configurable via an attribute. See **Attributes** below.

The functionality that was previously in the nagios::client recipe has been moved to its own NRPE cookbook at <https://github.com/sous-chefs/nrpe>

### Platform

- Debian 8+
- Ubuntu 14.04+
- Red Hat Enterprise Linux (CentOS/Amazon/Scientific/Oracle) 6+

**Notes**: This cookbook has been tested on the listed platforms. It may work on other platforms with or without modification.

### Cookbooks

- apache2 4.0 or greater
- build-essential
- nginx
- php
- yum-epel

## Attributes

### config

[The config file](https://github.com/sous-chefs/nagios/blob/master/attributes/config.rb) contains the Nagios configuration options. Consult the [nagios documentation](http://nagios.sourceforge.net/docs/3_0/configmain.html) for available settings and allowed options. Configuration entries of which multiple entries are allowed, need to be specified as an Array.

Example: `default['nagios']['conf']['cfg_dir'] = [ '/etc/nagios/conf.d' , '/usr/local/nagios/conf.d' ]`

### default
* `node['nagios']['user']` - Nagios user, default 'nagios'.
* `node['nagios']['group']` - Nagios group, default 'nagios'.
* `node['nagios']['plugin_dir']` - location where Nagios plugins go, default '/usr/lib/nagios/plugins'.
* `node['nagios']['multi_environment_monitoring']` - Chef server will monitor hosts in all environments, not just its own, default 'false'
* `node['nagios']['monitored_environments']` - If multi_environment_monitoring is 'true' nagios will monitor nodes in all environments. If monitored_environments is defined then nagios will monitor only hosts in the list of environments defined. For ex: ['prod', 'beta'] will monitor only hosts in 'prod' and 'beta' chef_environments. Defaults to '[]' - and all chef environments will be monitored by default.
* `node['nagios']['monitoring_interface']` - If set, will use the specified interface for all nagios monitoring network traffic. Defaults to `nil`
* `node['nagios']['exclude_tag_host']` - If set, hosts tagged with this value will be excluded from nagios monitoring.  Defaults to ''

* `node['nagios']['server']['install_method']` - whether to install from package or source. Default chosen by platform based on known packages available for Nagios: debian/ubuntu 'package', redhat/centos/scientific: source
* `node['nagios']['server']['install_yum-epel']` - whether to install the EPEL repo or not (only applies to RHEL platform family). The default value is `true`. Set this to `false` if you do not wish to install the EPEL RPM; in this scenario you will need to make the relevant packages available via another method e.g. local repo, or install from source.
* `node['nagios']['server']['service_name']` - name of the service used for Nagios, default chosen by platform, debian/ubuntu "nagios3", redhat family "nagios", all others, "nagios"
* `node['nagios']['home']` - Nagios main home directory, default "/usr/lib/nagios3"
* `node['nagios']['conf_dir']` - location where main Nagios config lives, default "/etc/nagios3"
* `node['nagios']['resource_dir']` - location for recources, default "/etc/nagios3"
* `node['nagios']['config_dir']` - location where included configuration files live, default "/etc/nagios3/conf.d"
* `node['nagios']['log_dir']` - location of Nagios logs, default "/var/log/nagios3"
* `node['nagios']['cache_dir']` - location of cached data, default "/var/cache/nagios3"
* `node['nagios']['state_dir']` - Nagios runtime state information, default "/var/lib/nagios3"
* `node['nagios']['run_dir']` - where pidfiles are stored, default "/var/run/nagios3"
* `node['nagios']['docroot']` - Nagios webui docroot, default "/usr/share/nagios3/htdocs"
* `node['nagios']['enable_ssl']` - boolean for whether Nagios web server should be https, default false
* `node['nagios']['ssl_cert_file']` = Location of SSL Certificate File. default "/etc/nagios3/certificates/nagios-server.pem"
* `node['nagios']['ssl_cert_chain_file']` = Optional location of SSL Intermediate Certificate File. No default.
* `node['nagios']['ssl_cert_key']`  = Location of SSL Certificate Key. default "/etc/nagios3/certificates/nagios-server.pem"
* `node['nagios']['ssl_protocols']` = The SSLProtocol string to pass to apache, defaults to "all -SSL3 -SSL2"
* `node['nagios']['ssl_ciphers']` = The SSLCipherSuite string to pass to apache, defaults to empty (which will result in this setting not being included in the apache config)
* `node['nagios']['http_port']` - port that the Apache/Nginx virtual site should listen on, determined whether ssl is enabled (443 if so, otherwise 80). Note:  You will also need to configure the listening port for either NGINX or Apache within those cookbooks.
* `node['nagios']['server_name']` - common name to use in a server cert, default "nagios"
* `node['nagios']['server']['server_alias']` - alias name for the webserver for use with Apache.  Defaults to nil
* `node['nagios']['ssl_req']` - info to use in a cert, default `/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node['nagios']['server_name']}/emailAddress=ops@#{node['nagios']['server_name']}`

*  `node['nagios']['server']['url']` - url to download the server source from if installing from source
*  `node['nagios']['server']['version']` - version of the server source to download
*  `node['nagios']['server']['checksum']` - checksum of the source files
*  `node['nagios']['server']['patch_url']` - url to download patches from if installing from source
*  `node['nagios']['server']['patches']` - array of patch filenames to apply if installing from source
*  `node['nagios']['url']` - URL to host Nagios from - defaults to nil and instead uses  FQDN

* `node['nagios']['conf']['enable_notifications']` - set to 1 to enable notification.
* `node['nagios']['conf']['interval_length']` - minimum interval. Defaults to '1'.
* `node['nagios']['conf']['use_timezone']` - set the timezone for nagios AND apache.  Defaults to UTC.
* `node['nagios']['conf']['use_large_installation_tweaks']` - Attribute to enable [large installation tweaks](http://nagios.sourceforge.net/docs/3_0/largeinstalltweaks.html). Defaults to 0.

* `node['nagios']['check_external_commands']`
* `node['nagios']['default_contact_groups']`
* `node['nagios']['default_user_name']` - Specify a defaut guest user to allow page access without authentication.  **Only** use this if nagios is running behind a secure webserver and users have been authenticated in some manner.  You'll likely want to change `node['nagios']['server_auth_require']` to `all granted`.  Defaults to `nil`.
* `node['nagios']['sysadmin_email']` - default notification email.
* `node['nagios']['sysadmin_sms_email']` - default notification sms.
* `node['nagios']['server_auth_method']` - authentication with the server can be done with openid (using `apache2::mod_auth_openid`), cas (using `apache2::mod_auth_cas`),ldap (using `apache2::mod_authnz_ldap`), or htauth (basic). The default is htauth. "openid" will utilize openid authentication, "cas" will utilize cas authentication, "ldap" will utilize LDAP authentication, and any other value will use htauth (basic).
* `node['nagios']['cas_login_url']` - login url for cas if using cas authentication.
* `node['nagios']['cas_validate_url']` - validation url for cas if using cas authentication.
* `node['nagios']['cas_validate_server']` - whether to validate the server cert. Defaults to off.
* `node['nagios']['cas_root_proxy_url']` - if set, sets the url that the cas server redirects to after auth.
* `node['nagios']['ldap_bind_dn']` - DN used to bind to the server when searching for ldap entries.
* `node['nagios']['ldap_bind_password']` - bind password used with the DN provided for searching ldap.
* `node['nagios']['ldap_url']` - ldap url and search parameters.
* `node['nagios']['ldap_authoritative']` - accepts "on" or "off". controls other authentication modules from authenticating the user if this one fails.
* `node['nagios']['ldap_group_attribute']` - Set the Apache AuthLDAPGroupAttribute directive to a non-default value.
* `node['nagios']['ldap_group_attribute_is_dn']` - accepts "on" or "off". Set the Apache AuthLDAPGroupAttributeIsDN directive. Apache's default behavior is currently "on."
* `node['nagios']['ldap_verify_cert']` - accepts "on" or "off". Set the Apache mod_ldap LDAPVerifyServerCert directive. Apache's default behavior is currently "on."
* `node['nagios']['ldap_trusted_mode']` - Set the Apache mod_ldap LDAPTrustedMode directive.
* `node['nagios']['ldap_trusted_global_cert']` - Set the Apache mod_ldap LDAPTrustedGlobalCert directive.
* `node['nagios']['users_databag']` - the databag containing users to search for. defaults to users
* `node['nagios']['users_databag_group']` - users databag group considered Nagios admins.  defaults to sysadmin
* `node['nagios']['services_databag']` - the databag containing services to search for. defaults to nagios_services
* `node['nagios']['servicegroups_databag']` - the databag containing servicegroups to search for. defaults to nagios_servicegroups
* `node['nagios']['templates_databag']` - the databag containing templates to search for. defaults to nagios_templates
* `node['nagios']['hostgroups_databag']` - the databag containing hostgroups to search for. defaults to nagios_hostgroups
* `node['nagios']['hosttemplates_databag']` - the databag containing host templates to search for. defaults to nagios_hosttemplates
* `node['nagios']['eventhandlers_databag']` - the databag containing eventhandlers to search for. defaults to nagios_eventhandlers
* `node['nagios']['unmanagedhosts_databag']` - the databag containing unmanagedhosts to search for. defaults to nagios_unmanagedhosts
* `node['nagios']['serviceescalations_databag']` - the databag containing serviceescalations to search for. defaults to nagios_serviceescalations
* `node['nagios']['hostescalations_databag']` - the databag containing hostescalations to search for. defaults to nagios_hostescalations
* `node['nagios']['contacts_databag']` - the databag containing contacts to search for. defaults to nagios_contacts
* `node['nagios']['contactgroups_databag']` - the databag containing contactgroups to search for. defaults to nagios_contactgroups
* `node['nagios']['servicedependencies_databag']` - the databag containing servicedependencies to search for. defaults to nagios_servicedependencies
* `node['nagios']['host_name_attribute']` - node attribute to use for naming the host. Must be unique across monitored nodes. Defaults to hostname
* `node['nagios']['regexp_matching']` - Attribute to enable [regexp matching](http://nagios.sourceforge.net/docs/3_0/configmain.html#use_regexp_matching). Defaults to 0.
* `node['nagios']['templates']` - These set directives in the default host template. Unless explicitly overridden, they will be inherited by the host definitions for each discovered node and `nagios_unmanagedhosts` data bag. For more information about these directives, see the Nagios documentation for [host definitions](http://nagios.sourceforge.net/docs/3_0/objectdefinitions.html#host).
* `node['nagios']['hosts_template']` - Host template you want to inherit properties/variables from, default 'server'. For more information, see the nagios doc on [Object Inheritance](http://nagios.sourceforge.net/docs/3_0/objectinheritance.html).
* `node['nagios']['brokers']` - Hash of broker modules to include in the config. Hash key is the path to the broker module, the value is any parameters to pass to it.


* `node['nagios']['default_host']['flap_detection']` - Defaults to `true`.
* `node['nagios']['default_host']['process_perf_data']` - Defaults to `false`.
* `node['nagios']['default_host']['check_period']` - Defaults to `'24x7'`.
* `node['nagios']['default_host']['check_interval']` - In seconds. Must be divisible by `node['nagios']['interval_length']`. Defaults to `15`.
* `node['nagios']['default_host']['retry_interval']` - In seconds. Must be divisible by `node['nagios']['interval_length']`. Defaults to `15`.
* `node['nagios']['default_host']['max_check_attempts']` - Defaults to `1`.
* `node['nagios']['default_host']['check_command']` - Defaults to the pre-defined command `'check-host-alive'`.
* `node['nagios']['default_host']['notification_interval']` - In seconds. Must be divisible by `node['nagios']['interval_length']`. Defaults to `300`.
* `node['nagios']['default_host']['notification_options']` - Defaults to `'d,u,r'`.
* `node['nagios']['default_host']['action_url']` - Defines a action url.  Defaults to `nil`.

* `node['nagios']['default_service']['process_perf_data']` - Defaults to `false`.
* `node['nagios']['default_service']['action_url']` - Defines a action url. Defaults to `nil`.

* `node['nagios']['server']['web_server']` - web server to use. supports Apache or Nginx, default "apache"
* `node['nagios']['server']['nginx_dispatch']` - nginx dispatch method. supports cgi or php, default "cgi"
* `node['nagios']['server']['stop_apache']` - stop apache service if using nginx, default false
* `node['nagios']['server']['redirect_root']` - if using Apache, should http://server/ redirect to http://server/nagios3 automatically, default false
* `node['nagios']['server']['normalize_hostname']` - If set to true, normalize all hostnames in hosts.cfg to lowercase. Defaults to false.

 These are nagios cgi.config options.

 * `node['nagios']['cgi']['show_context_help']`                         - Defaults to 1
 * `node['nagios']['cgi']['authorized_for_system_information']`         - Defaults to '*'
 * `node['nagios']['cgi']['authorized_for_configuration_information']`  - Defaults to '*'
 * `node['nagios']['cgi']['authorized_for_system_commands']`            - Defaults to '*'
 * `node['nagios']['cgi']['authorized_for_all_services']`               - Defaults to '*'
 * `node['nagios']['cgi']['authorized_for_all_hosts']`                  - Defaults to '*'
 * `node['nagios']['cgi']['authorized_for_all_service_commands']`       - Defaults to '*'
 * `node['nagios']['cgi']['authorized_for_all_host_commands']`          - Defaults to '*'
 * `node['nagios']['cgi']['default_statusmap_layout']`                  - Defaults to 5
 * `node['nagios']['cgi']['default_statuswrl_layout']`                  - Defaults to 4
 * `node['nagios']['cgi']['result_limit']`                              - Defaults to 100
 * `node['nagios']['cgi']['escape_html_tags']`                          - Defaults to 0
 * `node['nagios']['cgi']['action_url_target']`                         - Defaults to '_blank'
 * `node['nagios']['cgi']['notes_url_target']`                          - Defaults to '_blank'
 * `node['nagios']['cgi']['lock_author_names']`                         - Defaults to 1


Recipes
-------

## Recipes

### default

Includes the correct client installation recipe based on platform, either `nagios::server_package` or `nagios::server_source`.

The server recipe sets up Apache as the web front end by default. This recipe also does a number of searches to dynamically build the hostgroups to monitor, hosts that belong to them and admins to notify of events/alerts.

Searches are confined to the node's `chef_environment` unless multi-environment monitoring is enabled.

The recipe does the following:

1. Searches for users in 'users' databag belonging to a 'sysadmin' group, and authorizes them to access the Nagios web UI and also to receive notification e-mails.
2. Searches all available roles/environments and builds a list which will become the Nagios hostgroups.
3. Places nodes in Nagios hostgroups by role / environment membership.
4. Installs various packages required for the server.
5. Sets up configuration directories.
6. Moves the package-installed Nagios configuration to a 'dist' directory.
7. Disables the 000-default VirtualHost present on Debian/Ubuntu Apache2 package installations.
8. Templates configuration files for services, contacts, contact groups, templates, hostgroups and hosts.
9. Enables the Nagios web UI.
10. Starts the Nagios server service

### server_package

Installs the Nagios server from packages. Default for Debian / Ubuntu systems.

### server_source

Installs the Nagios server from source. Default for Red Hat based systems as native packages for Nagios are not available in the default repositories.

### pagerduty

Installs pagerduty plugin for nagios. If you only have a single pagerduty key, you can simply set a `node['nagios']['pagerduty_key']` attribute on your server. For multiple pagerduty key configuration see Pager Duty under Data Bags.

This recipe was written based on the [Nagios Integration Guide](http://www.pagerduty.com/docs/guides/nagios-integration-guide) from PagerDuty which explains how to get an API key for your Nagios server.

## Data Bags

[See Wiki for more databag information](https://github.com/sous-chefs/nagios/wiki/config)

### Pager Duty

You can define pagerduty contacts and keys by creating nagios_pagerduty data bags that contain the contact and the relevant key. Setting admin_contactgroup to "true" will add this pagerduty contact to the admin contact group created by this cookbook.

```javascript
{
  "id": "pagerduty_critical",
  "admin_contactgroup": "true",
  "key": "a33e5ef0ac96772fbd771ddcccd3ccd0"
}
```

You can add these contacts to any contactgroups you create.

## Monitoring Role

Create a role to use for the monitoring server. The role name should match the value of the attribute "`node['nrpe']['server_role']`" on your clients. By default, this is '`monitoring`'. For example:

```ruby
# roles/monitoring.rb
name 'monitoring'
description 'Monitoring server'
run_list(
  'recipe[nagios::default]'
)

default_attributes(
  'nagios' => {
    'server_auth_method' => 'htauth'
  }
)
```

```bash
$ knife role from file monitoring.rb
```

## Usage

### server setup

Create a role named '`monitoring`', and add the nagios server recipe to the `run_list`. See **Monitoring Role** above for an example.

Apply the nrpe cookbook to nodes in order to install the NRPE client

By default the Nagios server will only monitor systems in its same environment. To change this set the `multi_environment_monitoring` attribute. See **Attributes**

Create data bag items in the `users` data bag for each administer you would like to be able to login to the Nagios server UI. Pay special attention to the method you would like to use to authorization users (openid or htauth). See **Users** and **Atttributes**

At this point you now have a minimally functional Nagios server, however the server will lack any service checks outside of the single Nagios Server health check.

### defining checks

NRPE commands are defined in recipes using the nrpe_check LWRP provider in the nrpe cookbooks. For base system monitoring such as load, ssh, memory, etc you may want to create a cookbook in your environment that defines each monitoring command via the LWRP.

With NRPE commands created using the LWRP you will need to define Nagios services to use those commands. These services are defined using the `nagios_services` data bag and applied to roles and/or environments. See **Services**

### enabling notifications

You need to set `default['nagios']['notifications_enabled'] = 1` attribute on your Nagios server to enable email notifications.

For email notifications to work an appropriate mail program package and local MTA need to be installed so that /usr/bin/mail or /bin/mail is available on the system.

Example:

Include [postfix cookbook](https://github.com/opscode-cookbooks/postfix) to be installed on your Nagios server node.

Add override_attributes to your `monitoring` role:

```ruby
# roles/monitoring.rb
name 'monitoring'
description 'Monitoring Server'
run_list(
  'recipe[nagios:default]',
  'recipe[postfix]'
)

override_attributes(
  'nagios' => { 'notifications_enabled' => '1' },
  'postfix' => { 'myhostname':'your_hostname', 'mydomain':'example.com' }
)

default_attributes(
  'nagios' => { 'server_auth_method' => 'htauth' }
)
```

```bash
$ knife role from file monitoring.rb
```

## License & Authors

- Author:: Joshua Sierles [joshua@37signals.com](mailto:joshua@37signals.com)
- Author:: Nathan Haneysmith [nathan@chef.io](mailto:nathan@chef.io)
- Author:: Joshua Timberman [joshua@chef.io](mailto:joshua@chef.io)
- Author:: Seth Chisamore [schisamo@chef.io](mailto:schisamo@chef.io)
- Author:: Tim Smith [tsmith@chef.io](mailto:tsmith@chef.io)

```text
Copyright 2009, 37signals
Copyright 2009-2017, Chef Software, Inc
Copyright 2012, Webtrends Inc.
Copyright 2013-2014, Limelight Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
