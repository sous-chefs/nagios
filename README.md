Description
===========

Installs and configures Nagios server and NRPE client. Chef nodes are automatically discovered using search, and Nagios host groups are created based on Chef roles and optionally environments as well. NRPE client commands can be defined by using a LWRP, and Nagios service checks applied to hostgroups using definitions in data bag items.

Requirements
============

Chef
----

Chef version 0.10.10+ and Ohai 0.6.12+ are required.

Because of the heavy use of search, this recipe will not work with Chef Solo, as it cannot do any searches without a server.

This cookbook relies heavily on multiple data bags. See __Data Bag__ below.

The system running the 'server' recipe should have a role named 'monitoring' so that NRPE clients can authorize monitoring from that system. This role name is configurable via an attribute. See __Attributes__ below.


Platform
--------

* Debian 6
* Ubuntu 10.04, 12.04
* Red Hat Enterprise Linux (CentOS/Amazon/Scientific/Oracle) 5.9, 6.4

**Notes**: This cookbook has been tested on the listed platforms. It
  may work on other platforms with or without modification.

Cookbooks
---------

* apache2
* build-essential
* nginx
* nginx_simplecgi
* php
* yum

Attributes
==========

default
-------

The following attributes are used by both client and server recipes.

* `node['nagios']['user']` - Nagios user, default 'nagios'.
* `node['nagios']['group']` - Nagios group, default 'nagios'.
* `node['nagios']['plugin_dir']` - location where Nagios plugins go, default '/usr/lib/nagios/plugins'.
* `node['nagios']['multi_environment_monitoring']` - Chef server will monitor hosts in all environments, not just its own, default 'false'
* `node['nagios']['multi_environment_filter']` - If `multi_environment_monitoring` is enabled, and this is set, then the value of this attribute will be appended to the search query. This allows you to exclude results from the search, like 'NOT chef_environment:default', etc. Default is nil.

client
------

The following attributes are used for the NRPE client

* `node['nagios']['client']['install_method']` - whether to install from package or source. Default chosen by platform based on known packages available for NRPE: debian/ubuntu 'package', Redhat/CentOS/Fedora/Scientific: source
* `node['nagios']['plugins']['url']` - url to retrieve the plugins source
* `node['nagios']['plugins']['version']` - version of the plugins source to download
* `node['nagios']['plugins']['checksum']` - checksum of the plugins source tarball
* `node['nagios']['nrpe']['home']` - home directory of NRPE, default /usr/lib/nagios
* `node['nagios']['nrpe']['conf_dir']` - location of the nrpe configuration, default /etc/nagios
* `node['nagios']['nrpe']['url']` - url to retrieve NRPE source
* `node['nagios']['nrpe']['version']` - version of NRPE source to download
* `node['nagios']['nrpe']['checksum']` - checksum of the NRPE source tarball
* `node['nagios']['nrpe']['packages']` - nrpe / plugin packages to install. The default attribute for RHEL/Fedora platforms contains a bare minimum set of packages. The full list of available packages is available at: `http://dl.fedoraproject.org/pub/epel/6/x86_64/repoview/letter_n.group.html`
* `node['nagios']['server_role']` - the role that the Nagios server will have in its run list that the clients can search for.
* `node['nagios']['allowed_hosts']` - additional hosts that are allowed to connect to this client. Must be an array of strings (i.e. `%w(test.host other.host)`). These hosts are added in addition to 127.0.0.1 and IPs that are found via search.

server
------

The following attributes are used for the Nagios server

* `node['nagios']['server']['install_method']` - whether to install from package or source. Default chosen by platform based on known packages available for Nagios: debian/ubuntu 'package', redhat/centos/fedora/scientific: source
* `node['nagios']['server']['service_name']` - name of the service used for Nagios, default chosen by platform, debian/ubuntu "nagios3", redhat family "nagios", all others, "nagios"
* `node['nagios']['home']` - Nagios main home directory, default "/usr/lib/nagios3"
* `node['nagios']['conf_dir']` - location where main Nagios config lives, default "/etc/nagios3"
* `node['nagios']['config_dir']` - location where included configuration files live, default "/etc/nagios3/conf.d"
* `node['nagios']['log_dir']` - location of Nagios logs, default "/var/log/nagios3"
* `node['nagios']['cache_dir']` - location of cached data, default "/var/cache/nagios3"
* `node['nagios']['state_dir']` - Nagios runtime state information, default "/var/lib/nagios3"
* `node['nagios']['run_dir']` - where pidfiles are stored, default "/var/run/nagios3"
* `node['nagios']['docroot']` - Nagios webui docroot, default "/usr/share/nagios3/htdocs"
* `node['nagios']['enable_ssl]` - boolean for whether Nagios web server should be https, default false
* `node['nagios']['ssl_cert_file']` = Location of SSL Certificate File. default "/etc/nagios3/certificates/nagios-server.pem"
* `node['nagios']['ssl_cert_key']`  = Location of SSL Certificate Key. default "/etc/nagios3/certificates/nagios-server.pem"
* `node['nagios']['http_port']` - port that the Apache/Nginx virtual site should listen on, determined whether ssl is enabled (443 if so, otherwise 80). Note:  You will also need to configure the listening port for either NGINX or Apache within those cookbooks.
* `node['nagios']['server_name']` - common name to use in a server cert, default "nagios"
* `node['nagios']['ssl_req']` - info to use in a cert, default `/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node['nagios']['server_name']}/emailAddress=ops@#{node['nagios']['server_name']}`

*  `node['nagios']['server']['url']` - url to download the server source from if installing from source
*  `node['nagios']['server']['version']` - version of the server source to download
*  `node['nagios']['server']['checksum']` - checksum of the source files
*  `node['nagios']['url']` - URL to host Nagios from - defaults to nil and instead uses  FQDN

* `node['nagios']['notifications_enabled']` - set to 1 to enable notification.
* `node['nagios']['check_external_commands']`
* `node['nagios']['default_contact_groups']`
* `node['nagios']['additional_contacts']` - additional contacts to be utilized for notifying of status changes. Example: `node['nagios']['additional_contacts']['pagerduty'] = true`.
* `node['nagios']['sysadmin_email']` - default notification email.
* `node['nagios']['sysadmin_sms_email']` - default notification sms.
* `node['nagios']['server_auth_method']` - authentication with the server can be done with openid (using `apache2::mod_auth_openid`), cas (using `apache2::mod_auth_cas`),ldap (using `apache2::mod_authnz_ldap`), or htauth (basic). The default is openid, "cas" will utilize cas authentication, "ldap" will utilize LDAP authentication, and any other value will use htauth (basic).
* `node['nagios']['cas_login_url']` - login url for cas if using cas authentication.
* `node['nagios']['cas_validate_url']` - validation url for cas if using cas authentication.
* `node['nagios']['cas_validate_server']` - whether to validate the server cert. Defaults to off.
* `node['nagios']['cas_root_proxy_url']` - if set, sets the url that the cas server redirects to after auth.
* `node['nagios']['ldap_bind_dn']` - DN used to bind to the server when searching for ldap entries.
* `node['nagios']['ldap_bind_password']` - bind password used with the DN provided for searcing ldap.
* `node['nagios']['ldap_url']` - ldap url and search parameters.
* `node['nagios']['ldap_authoritative']` - accepts "on" or "off". controls other authentication modules from authenticating the user if this one fails.
* `node['nagios']['users_databag']` - the databag containing users to search for. defaults to users
* `node['nagios']['users_databag_group']` - users databag group considered Nagios admins.  defaults to sysadmin
* `node['nagios']['host_name_attribute']` - node attribute to use for naming the host. Must be unique across monitored nodes. Defaults to hostname
* `node['nagios']['templates']`
* `node['nagios']['interval_length']` - minimum interval.

* `node['nagios']['default_host']['check_interval']`
* `node['nagios']['default_host']['retry_interval']`
* `node['nagios']['default_host']['max_check_attempts']`
* `node['nagios']['default_host']['notification_interval']`

* `node['nagios']['default_service']['check_interval']`
* `node['nagios']['default_service']['retry_interval']`
* `node['nagios']['default_service']['max_check_attempts']`
* `node['nagios']['default_service']['notification_interval']`

* `node['nagios']['server']['web_server']` - web server to use. supports Apache or Nginx, default "apache"
* `node['nagios']['server']['nginx_dispatch']` - nginx dispatch method. support cgi or php, default "cgi"
* `node['nagios']['server']['stop_apache']` - stop apache service if using nginx, default false
* `node['nagios']['server']['redirect_root']` - if using Apache, should http://server/ redirect to http://server/nagios3 automatically, default false
* `node['nagios']['server']['normalize_hostname']` - If set to true, normalize all hostnames in hosts.cfg to lowercase. Defaults to false.


Recipes
=======

default
-------

Includes the `nagios::client` recipe to install NRPE client.

client
------

Includes the correct NRPE client installation recipe based on platform, either `nagios::client_package` or `nagios::client_source`.

The client recipe searches for servers allowed to connect via NRPE that have a role named in the `node['nagios']['server_role']` attribute. The recipe will also install the required packages and start the NRPE service. A custom plugin for checking memory is also added.

Searches are confined to the node's `chef_environment` unless the `multi_environment_monitoring` attribute has been set to true.

Client commands for NRPE can be installed using the nrpecheck lwrp. (See __Resources/Providers__ below.)

RHEL and Fedora default to installation via source, but you can install NRPE via package by changing `node['nagios']['client']['install_method']` to "package". Note that this will enable the EPEL repository on RHEL systems, which may not be desired. You will also need to modify `node['nagios']['nrpe']['packages']` to include the appropriate NRPE plugins for your environment. The complete list is available at `http://dl.fedoraproject.org/pub/epel/6/x86_64/repoview/letter_n.group.html`

client\_package
---------------

Installs the NRPE client and plugins from packages. Default for Debian / Ubuntu systems.

client\_source
--------------

Installs the NRPE client and plugins from source. Default for Redhat and Fedora based systems, as native packages for NRPE are not available in the default repositories.

server
------

Includes the correct client installation recipe based on platform, either `nagios::server_package` or `nagios::server_source`.

The server recipe sets up Apache as the web front end by default. The nagios::client recipe is also included. This recipe also does a number of searches to dynamically build the hostgroups to monitor, hosts that belong to them and admins to notify of events/alerts.

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


server\_package
---------------

Installs the Nagios server from packages. Default for Debian / Ubuntu systems.

server\_source
--------------

Installs the Nagios server from source. Default for Red Hat / Fedora based systems as native packages for Nagios are not available in the default repositories.

pagerduty
---------

Installs and configures pagerduty plugin for Nagios. You need to set a `node['nagios']['pagerduty_key']` attribute on your server for this to work. This can be set through environments so that you can use different API keys for servers in production vs staging for instance.

This recipe was written based on the [Nagios Integration Guide](http://www.pagerduty.com/docs/guides/nagios-integration-guide) from PagerDuty which explains how to get an API key for your Nagios server.


Data Bags
=========

Users
-----

Create a `users` data bag that will contain the users that will be able to log into the Nagios webui. Each user can use htauth with a specified password, or an openid. Users that should be able to log in should be in the sysadmin group. Example user data bag item:

    {
      "id": "nagiosadmin",
      "groups": "sysadmin",
      "htpasswd": "hashed_htpassword",
      "openid": "http://nagiosadmin.myopenid.com/",
      "nagios": {
        "pager": "nagiosadmin_pager@example.com",
        "email": "nagiosadmin@example.com"
      }
    }

When using `server_auth_method` 'openid' (default), use the openid in the data bag item. Any other value for this attribute (e.g., "htauth", "htpasswd", etc) will use the htpasswd value as the password in `/etc/nagios3/htpasswd.users`.

The openid must have the http:// and trailing /. The htpasswd must be the hashed value. Get this value with htpasswd:

    % htpasswd -n -s nagiosadmin
    New password:
    Re-type new password:
    nagiosadmin:{SHA}oCagzV4lMZyS7jl2Z0WlmLxEkt4=

For example use the `{SHA}oCagzV4lMZyS7jl2Z0WlmLxEkt4=` value in the data bag.

Contacts and Contact Groups
---------------------------

To send alerting notification to contacts that aren't authorized to login to Nagios via the 'users' data bag create `nagios_contacts` and `nagios_contactgroups` data bags.

Example `nagios_contacts` data bag item

    {
	  "id": "devs",
      "alias": "Developers",
	  "use": "default-contact",
      "email": "devs@company.com",
      "pager": "page_the_devs@company.com"
    }


Example `nagios_contactgroup` data bag item

    {
	  "id": "non_admins",
      "alias": "Non-Administrator Contacts",
      "members": "devs helpdesk managers"
    }


Services
--------

To add service checks to Nagios create a `nagios_services` data bag containing definitions for services to be monitored. This allows you to add monitoring rules without directly editing the services and commands templates in the cookbook. Each service will be named based on the id of the data bag item and the command will be named using the same id prepended with "check\_". Just make sure the id in your data bag doesn't conflict with a service or command already defined in the templates.

Here's an example of a service check for sshd that you could apply to all hostgroups:

    {
	  "id": "ssh",
      "hostgroup_name": "linux",
	  "command_line": "$USER1$/check_ssh $HOSTADDRESS$"
    }

You may optionally define the service template for your service by including `service_template` and a valid template name. Example:  "service_template": "special_service_template". You may also optionally add a service description that will be displayed in the Nagios UI using "description": "My Service Name". If this is not present the databag item ID will be used as the description. You use defined escalations for the service with 'use_escalation'. See ___Service_Escalations__ for more information.

You may also use an already defined command definition by omitting the command\_line parameter and using use\_existing\_command parameter instead:

    {
    "id": "pingme",
     "hostgroup_name": "all",
     "use_existing_command": "check-host-alive"
    }

Service Groups
--------------

Create a nagios\_servicegroups data bag that will contain definitions for service groups. Each server group will be named based on the id of the data bag.

    {
    "id": "ops",
    "alias": "Ops",
    "notes": "Services for ops"
    }

You can group your services by using the "servicegroups" keyword in your services data bags. For example, to have your ssh
checks show up under the ops service group, you could define it like this:

    {
    "id": "ssh",
    "hostgroup_name": "all",
    "command_line": "$USER1$/check_ssh $HOSTADDRESS$",
    "servicegroups": "ops"
    }

Templates
---------

Templates are optional, but allow you to specify combinations of attributes to apply to a service. Create a nagios_templates\ data bag that will contain definitions for templates to be used. Each template need only specify id and whichever parameters you want to override.

Here's an example of a template that reduces the check frequency to once per day and changes the retry interval to 1 hour.

    {
      "id": "dailychecks",
      "check_interval": "86400",
      "retry": "3600"
    }

You then use the template in your service data bag as follows:

    {
      "id": "expensive_service_check",
      "hostgroup_name": "linux",
      "command_line": "$USER1$/check_example $HOSTADDRESS$",
      "service_template": "dailychecks"
    }

Search Defined Hostgroups
-------------------------

Create a nagios\_hostgroups data bag that will contain definitions for Nagios hostgroups populated via search. These data bags include a Chef node search query that will populate the Nagios hostgroup with nodes based on the search.

Here's an example to find all HP hardware systems for an "hp_systems" hostgroup:

	{
	  "search_query": "dmi_system_manufacturer:HP",
	  "hostgroup_name": "hp_systems",
	  "id": "hp_systems"
	}

Monitoring Systems Not In Chef
------------------------------

Create a nagios\_unmanagedhosts data bag that will contain definitions for hosts not in Chef that you would like to manage. "hostgroups" can be an existing Chef role (every Chef role gets a Nagios hostgroup) or a new hostgroup. Note that "hostgroups" must be an array of hostgroups even if it contains just a single hostgroup.

Here's an example host definition:

	{
	  "address": "webserver1.mydmz.dmz",
	  "hostgroups": ["web_servers","production_servers"],
	  "id": "webserver1",
	  "notifications": 1
	}

Service Escalations
-------------------

You can optionally define service escalations for the data bag defined services. Doing so involves two steps - creating the `nagios_serviceescalations` data bag and invoking it from the service. For example, to create an escalation to page managers on a 15 minute period after the 3rd page:

	{
      "id": "15-minute-escalation",
      "contact_groups": "managers",
      "first_notification": "3",
      "last_notification": "0",
      "escalation_period": "24x7",
      "notification_interval": "900"
	}

Then, in the service data bag,

	{
      "id": "my-service",
      ...
      "use_escalation": "15-minute-escalation"
	}

Event Handlers
--------------

You can optionally define event handlers to trigger on service alerts by creating a nagios\_eventhandlers data bag that will contain definitions of event handlers for services monitored via Nagios.

This example event handler data bags restarts chef-client. Note: This assumes you have already defined a NRPE job restart\_chef-client on the host where this command will run. You can use the NRPE LWRP to add commands to your local NRPE configs from within your cookbooks.

	{
      "command_line": "$USER1$/check_nrpe -H $HOSTADDRESS$ -t 45 -c restart_chef-client",
      "id": "restart_chef-client"
	}

Once you've defined an event handler you will need to add the event handler to a service definition in order to trigger the action. See the example service definition below.

	{
      "command_line": "$USER1$/check_nrpe -H $HOSTADDRESS$ -t 45 -c check_chef_client",
      "hostgroup_name": "linux",
      "id": "chef-client",
      "event_handler": "restart_chef-client"
	}


Monitoring Role
===============

Create a role to use for the monitoring server. The role name should match the value of the attribute "`node['nagios']['server_role']`". By default, this is '`monitoring`'. For example:

    % cat roles/monitoring.rb
    name "monitoring"
    description "Monitoring server"
    run_list(
      "recipe[nagios::server]"
    )

    default_attributes(
      "nagios" => {
        "server_auth_method" => "htauth"
      }
    )

    % knife role from file monitoring.rb


Definitions
===========

nagios_conf
-----------

This definition is used to drop in a configuration file in the base Nagios configuration directory's conf.d. This can be used for customized configurations for various services.

Libraries
=========

default
-------

The library included with the cookbook provides some helper methods used in templates.

* `nagios_boolean`
* `nagios_interval` - calculates interval based on interval length and a given number of seconds.
* `nagios_attr` - retrieves a nagios attribute from the node.

Resources/Providers
===================

nrpecheck
---------

The nrpecheck LWRP provides an easy way to add and remove NRPE checks from within cookbooks.

### Actions

- `:add` creates a NRPE configuration file and restart the NRPE process. Default action.
- `:remove` removes the configuration file and restart the NRPE process

### Attribute Parameters

- `command_name`  The name of the check. This is the command that you will call from your nagios\_service data bag check
- `warning_condition` String that you will pass to the command with the -w flag
- `critical_condition` String that you will pass to the command with the -c flag
- `command` The actual command to execute (including the path). If this is not specified, this will use `node['nagios']['plugin_dir']/command_name` as the path to the command.
- `parameters` Any additional parameters you wish to pass to the plugin.

### Examples

    # Use LWRP to define check_load
    nagios_nrpecheck "check_load" do
      command "#{node['nagios']['plugin_dir']}/check_load"
      warning_condition node['nagios']['checks']['load']['warning']
      critical_condition node['nagios']['checks']['load']['critical']
      action :add
    end

    # Remove the check_load definition
    nagios_nrpecheck "check_load" do
      action :remove
    end

Usage
=====

server setup
------------

Create a role named '`monitoring`', and add the nagios server recipe to the `run_list`. See __Monitoring Role__ above for an example.

Apply the Nagios client recipe to nodes in order to install the NRPE client

By default the Nagios server will only monitor systems in its same environment. To change this set the `multi_environment_monitoring` attribute. See __Attributes__

Create data bag items in the `users` data bag for each administer you would like to be able to login to the Nagios server UI. Pay special attention to the method you would like to use to authorization users (openid or htauth). See __Users__ and __Atttributes__

At this point you now have a minimally functional Nagios server, however the server will lack any service checks outside of the single Nagios Server health check.

defining checks
---------------

NRPE commands are defined in recipes using the nrpecheck LWRP provider. For base system monitoring such as load, ssh, memory, etc you may want to create a cookbook in your environment that defines each monitoring command via the LWRP. See the examples folder for an example of base monitoring.

With NRPE commands created using the LWRP you will need to define Nagios services to use those commands. These services are defined using the `nagios_services` data bag and applied to roles and/or environments. See __Services__

enabling notifications
----------------------

You need to set `default['nagios']['notifications_enabled'] = 1` attribute on your Nagios server to enable email notifications.

For email notifications to work an appropriate mail program package and local MTA need to be installed so that /usr/bin/mail or /bin/mail is available on the system.

Example:

Include [postfix cookbook](https://github.com/opscode-cookbooks/postfix) to be installed on your Nagios server node.

Add override_attributes to your `monitoring` role:

    % cat roles/monitoring.rb

    name "monitoring"
    description "Monitoring Server"
    run_list(
      "recipe[nagios::server]",
      "recipe[postfix]"
    )

    override_attributes(
      "nagios" => { "notifications_enabled" => "1" },
      "postfix" => { "myhostname":"your_hostname", "mydomain":"example.com" }
    )

    default_attributes(
      "nagios" => { "server_auth_method" => "htauth" }
    )

    % knife role from file monitoring.rb


License and Author
==================

Author:: Joshua Sierles <joshua@37signals.com>
Author:: Nathan Haneysmith <nathan@opscode.com>
Author:: Joshua Timberman <joshua@opscode.com>
Author:: Seth Chisamore <schisamo@opscode.com>
Author:: Tim Smith <tsmith84@gmail.com>

Copyright 2009, 37signals
Copyright 2009-2013, Opscode, Inc
Copyright 2012, Webtrends Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
