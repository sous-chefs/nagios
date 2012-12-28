Description
===========

Installs and configures Nagios 3 for a server and NRPE for clients using Chef search capabilities.

Requirements
============

Chef
----

Chef version 0.10.10+ and Ohai 0.6.12+ are required.

A data bag named 'users' should exist, see __Data Bag__ below.

The monitoring server that uses this recipe should have a role named 'monitoring' or similar, the role name is configurable via an attribute. See __Attributes__ below.

Because of the heavy use of search, this recipe will not work with Chef Solo, as it cannot do any searches without a server.

By default NRPE clients can only be monitored by Nagios servers in the same environment. To change this set the multi_environment_monitoring attribute. See __Attributes__ below.

Platform
--------

* Debian 6
* Ubuntu 10.04, 12.04
* Red Hat Enterprise Linux (CentOS/Amazon/Scientific/Oracle) 5.8, 6.3

**Notes**: This cookbook has been tested on the listed platforms. It
  may work on other platforms with or without modification.

Cookbooks
---------

* apache2
* build-essential
* php
* nginx
* nginx_simplecgi

Attributes
==========

default
-------

The following attributes are used by both client and server recipes.

* `node['nagios']['user']` - nagios user, default 'nagios'.
* `node['nagios']['group']` - nagios group, default 'nagios'.
* `node['nagios']['plugin_dir']` - location where nagios plugins go, default '/usr/lib/nagios/plugins'.
* `node['nagios']['multi_environment_monitoring']` - Chef server will monitor hosts in all environments, not just its own, default 'false'

client
------

The following attributes are used for the client NRPE checks for warning and critical levels.

* `node['nagios']['client']['install_method']` - whether to install from package or source. Default chosen by platform based on known packages available for Nagios 3: debian/ubuntu 'package', redhat/centos/fedora/scientific: source
* `node['nagios']['plugins']['url']` - url to retrieve the plugins source
* `node['nagios']['plugins']['version']` - version of the plugins
* `node['nagios']['plugins']['checksum']` - checksum of the plugins source tarball
* `node['nagios']['nrpe']['home']` - home directory of nrpe, default /usr/lib/nagios
* `node['nagios']['nrpe']['conf_dir']` - location of the nrpe configuration, default /etc/nagios
* `node['nagios']['nrpe']['url']` - url to retrieve nrpe source
* `node['nagios']['nrpe']['version']` - version of nrpe to download
* `node['nagios']['nrpe']['checksum']` - checksum of the nrpe source tarball
* `node['nagios']['checks']['memory']['critical']` - threshold of critical memory usage, default 150
* `node['nagios']['checks']['memory']['warning']` - threshold of warning memory usage, default 250
* `node['nagios']['checks']['load']['critical']` - threshold of critical load average, default 30,20,10
* `node['nagios']['checks']['load']['warning']` - threshold of warning load average, default 15,10,5
* `node['nagios']['checks']['smtp_host']` - default relayhost to check for connectivity. Default is an empty string, set via an attribute in a role.
* `node['nagios']['server_role']` - the role that the nagios server will have in its run list that the clients can search for.

server
------

Default directory locations are based on FHS. Change to suit your preferences.

* `node['nagios']['server']['install_method']` - whether to install from package or source. Default chosen by platform based on known packages available for Nagios 3: debian/ubuntu 'package', redhat/centos/fedora/scientific: source
* `node['nagios']['server']['service_name']` - name of the service used for nagios, default chosen by platform, debian/ubuntu "nagios3", redhat family "nagios", all others, "nagios"
* `node['nagios']['server']['web_server']` - web server to use. supports apache or nginx, default "apache"
* `node['nagios']['server']['nginx_dispatch']` - nginx dispatch method. support cgi or php, default "cgi"
* `node['nagios']['server']['stop_apache']` - stop apache service if using nginx, default false
* `node['nagios']['server']['redirect_root']` - if using apache, should http://server/ redirect to http://server//nagios3 automatically, default false
* `node['nagios']['home']` - nagios main home directory, default "/usr/lib/nagios3"
* `node['nagios']['conf_dir']` - location where main nagios config lives, default "/etc/nagios3"
* `node['nagios']['config_dir']` - location where included configuration files live, default "/etc/nagios3/conf.d"
* `node['nagios']['log_dir']` - location of nagios logs, default "/var/log/nagios3"
* `node['nagios']['cache_dir']` - location of cached data, default "/var/cache/nagios3"
* `node['nagios']['state_dir']` - nagios runtime state information, default "/var/lib/nagios3"
* `node['nagios']['run_dir']` - where pidfiles are stored, default "/var/run/nagios3"
* `node['nagios']['docroot']` - nagios webui docroot, default "/usr/share/nagios3/htdocs"
* `node['nagios']['enable_ssl]` - boolean for whether nagios web server should be https, default false
* `node['nagios']['http_port']` - port that the apache server should listen on, determined whether ssl is enabled (443 if so, otherwise 80)
* `node['nagios']['server_name']` - common name to use in a server cert, default "nagios"
* `node['nagios']['ssl_req']` - info to use in a cert, default `/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node['nagios']['server_name']}/emailAddress=ops@#{node['nagios']['server_name']}`

* `node['nagios']['notifications_enabled']` - set to 1 to enable notification.
* `node['nagios']['check_external_commands']`
* `node['nagios']['default_contact_groups']`
* `node['nagios']['sysadmin_email']` - default notification email.
* `node['nagios']['sysadmin_sms_email']` - default notification sms.
* `node['nagios']['users_databag_group']` - Users databag group considered Nagios admins.  Defaults to sysadmins
* `node['nagios']['host_name_attribute']` - node attribute to use for naming the host. Must be unique across monitored nodes. Defaults to hostname
* `node['nagios']['server_auth_method']` - authentication with the server can be done with openid (using `apache2::mod_auth_openid`), or htauth (basic). The default is openid, any other value will use htauth (basic).
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

Recipes
=======

default
-------

Includes the `nagios::client` recipe.

client
------

Includes the correct client installation recipe based on platform, either `nagios::client_package` or `nagios::client_source`.

The client recipe searches for servers allowed to connect via NRPE that have a role named in the `node['nagios']['server_role']` attribute. The recipe will also install the required packages and start the NRPE service. A custom plugin for checking memory is also added.

Searches are confined to the node's `chef_environment`.

Client commands for NRPE can be installed using the nrpecheck resource. (See __Resources/Providers__ below.)

client\_package
---------------

Installs the Nagios client libraries from packages. Default for Debian / Ubuntu systems.

client\_source
--------------

Installs the Nagios client libraries from source. Default for Red Hat / CentOS / Fedora systems as native packages of Nagios 3 are not available in the default repositories.

server
------

Includes the correct client installation recipe based on platform, either `nagios::server_package` or `nagios::server_source`.

The server recipe sets up Apache as the web front end. The nagios::client recipe is also included. This recipe also does a number of searches to dynamically build the hostgroups to monitor, hosts that belong to them and admins to notify of events/alerts.

Searches are confined to the node's `chef_environment`.

The recipe does the following:

1. Searches for members of the sysadmins group by searching through 'users' data bag and adds them to a list for notification/contacts.
2. Search all nodes for a role matching the app_environment.
3. Search all available roles and build a list which will be the Nagios hostgroups.
4. Search for all nodes of each role and add the hostnames to the hostgroups.
5. Installs various packages required for the server.
6. Sets up some configuration directories.
7. Moves the package-installed Nagios configuration to a 'dist' directory.
8. Disables the 000-default VirtualHost present on Debian/Ubuntu Apache2 package installations.
9. Enables the Nagios web front end configuration.
10. Sets up the configuration templates for services, contacts, hostgroups and hosts.

*NOTE*: You will probably need to change the services.cfg.erb template for your environment.

To add custom commands for service checks, these can be done on a per-role basis by editing the 'services.cfg.erb' template. This template has some pre-configured checks that use role names used in an example infrastructure. Here's a brief description:

* monitoring - check_smtp (e.g., postfix relayhost) w/ NRPE and tcp port 514 (e.g., rsyslog)
* load\_balancer - check_nginx with NRPE.
* appserver - check_unicorn with NRPE, e.g. a Rails application using Unicorn.
* database\_master - check\_mysql\_server with NRPE for a MySQL database master.

server\_package
---------------

Installs the Nagios server libraries from packages. Default for Debian / Ubuntu systems.

server\_source
--------------

Installs the Nagios server libraries from source. Default for Red Hat / CentOS / Fedora systems as native packages of Nagios 3 are not available in the default repositories.

pagerduty
---------

Installs and configures pagerduty plugin for nagios.  You need to set a `node['nagios']['pagerduty_key']` attribute on your server for this to work.  This can be set through environments so that you can use different API keys for servers in production vs staging for instance.

This recipe was written based on the [Nagios Integration Guide](http://www.pagerduty.com/docs/guides/nagios-integration-guide) from PagerDuty which explains how to get an API key for your nagios server.

email notifications
--------------------

You need to set `default['nagios']['notifications_enabled'] = 1` attribute on your nagios server to enable email notifications.

For email notifications to work an appropriate mail program package and local MTA need to be installed so that /usr/bin/mail or /bin/mail is available on the system.

Example:

Include [postfix cookbook](https://github.com/opscode-cookbooks/postfix) to be installed on your nagios server node.

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

When using server_auth_method 'openid', use the openid in the data bag item. Any other value for this attribute (e.g., "htauth", "htpasswd", etc) will use the htpasswd value as the password in `/etc/nagios3/htpasswd.users`.

The openid must have the http:// and trailing /. The htpasswd must be the hashed value. Get this value with htpasswd:

    % htpasswd -n -s nagiosadmin
    New password:
    Re-type new password:
    nagiosadmin:{SHA}oCagzV4lMZyS7jl2Z0WlmLxEkt4=

For example use the `{SHA}oCagzV4lMZyS7jl2Z0WlmLxEkt4=` value in the data bag.

Services
--------

Create a nagios\_services data bag that will contain definitions for services to be monitored.  This allows you to add monitoring rules without mucking about in the services and commands templates.  Each service will be named based on the id of the data bag and the command will be named withe the same id prepended with "check\_".  Just make sure the id in your data bag doesn't conflict with a service or command already defined in the templates.

Here's an example of a service check for sshd that you could apply to all hostgroups:

    {
    "id": "ssh",
    "hostgroup_name": "all",
    "command_line": "$USER1$/check_ssh $HOSTADDRESS$"
    }

You may optionally define the service template for your service by including service_template and a valid template name.  Example:  "service_template": "special_service_template".  You may also optionally add a service description that will be displayed in the Nagios UI using "description": "My Service Name".  If this is not present the databag name will be used.

Templates
---------

Templates are optional, but allow you to specify combinations of attributes to apply to a service.  Create a nagios_templates\ data bag that will contain definitions for templates to be used.  Each template need only specify id and whichever parameters you want to override.

Here's an example of a template that reduces the check frequency to once per day and changes the retry interval to 1 hour.

    {
    "id": "dailychecks",
    "check_interval": "86400",
    "retry": "3600"
    }

You then use the template in your service data bag as follows:

    {
    "id": "expensive_service_check",
    "hostgroup_name": "all",
    "command_line": "$USER1$/check_example $HOSTADDRESS$",
    "service_template": "dailychecks"
    }

Search Defined Hostgroups
-------------------------

Create a nagios\_hostgroups data bag that will contain definitions for Nagios hostgroups populated via search.  These data bags include a Chef node search query that will populate the Nagios hostgroup with nodes based on the search.

Here's an example to find all HP hardware systems for an "hp_systems" hostgroup:

		{
		"search_query": "dmi_system_manufacturer:HP",
		"hostgroup_name": "hp_systems",
		"id": "hp_systems"
		}

Monitoring Systems Not In Chef
------------------------------

Create a nagios\_unmanagedhosts data bag that will contain definitions for hosts not in Chef that you would like to manage.  "hostgroups" can be an existing Chef role (every Chef role gets a Nagios hostgroup) or a new hostgroup.
Here's an example host definition:

		{
		"address": "webserver1.mydmz.dmz",
		"hostgroups": ["web_servers","production_servers"],
		"id": "webserver1",
		"notifications": 1
		}


Roles
=====

Create a role to use for the monitoring server. The role name should match the value of the attribute "nagios[:server_role]". By default, this is 'monitoring'. For example:

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


Event Handlers
=====

You can optionally define event handlers to trigger on service alerts by creating a nagios\_eventhandlers data bag that will contain definitions of event handlers for services monitored via Nagios.

This example event handler data bags restarts chef-client.  Note: This assumes you have already defined a NRPE job restart\_chef-client on the host where this command will run.  You can use the NRPE LWRP to add commands to your local NRPE configs from within your cookbooks.

{
    "command_line": "$USER1$/check_nrpe -H $HOSTADDRESS$ -t 45 -c restart_chef-client",
    "id": "restart_chef-client"
}

Once you've defined an event handler you will need to add the event handler to a service definition in order to trigger the action.  See the example service definition below.

{
    "command_line": "$USER1$/check_nrpe -H $HOSTADDRESS$ -t 45 -c check_chef_client",
    "hostgroup_name": "linux",
    "id": "chef-client",
    "event_handler": "restart_chef-client"
}


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

* nagios_boolean
* nagios_interval - calculates interval based on interval length and a given number of seconds.
* nagios_attr - retrieves a nagios attribute from the node.

Resources/Providers
===================

The nrpecheck LWRP provides an easy way to add and remove NRPE checks from within a cookbook.

# Actions

- :add: creates a NRPE configuration file and restart the NRPE process. Default action.
- :remove: removes the configuration file and restart the NRPE process

# Attribute Parameters

- command_name: name attribute.  The name of the check.  You'll need to reference this in your commands.cfg template
- warning_condition: String that you will pass to the command with the -w flag
- critical_condition: String that you will pass to the command with the -c flag
- command: The actual command to execute (including the path). If this is not specified, this will use `node['nagios']['plugin_dir']/command_name` as the path to the command.
- parameters: Any additional parameters you wish to pass to the plugin.

# Examples

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

See below under __Environments__ for how to set up Chef 0.10 environment for use with this cookbook.

For a Nagios server, create a role named 'monitoring', and add the following recipe to the run_list:

    recipe[nagios::server]

This will allow client nodes to search for the server by this role and add its IP address to the allowed list for NRPE.

To install Nagios and NRPE on a client node:

    include_recipe "nagios::client"

This is a fairly complicated cookbook. For a walkthrough and example usage please see [Opscode's Nagios Quick Start](http://help.opscode.com/kb/otherhelp/nagios-quick-start).

Environments
------------

The searches used are confined to the node's `chef_environment`. If you do not use any environments (Chef 0.10+ feature) the `_default` environment is used, which is applied to all nodes in the Chef Server that are not in another defined role. To use environments, create them as files in your chef-repo, then upload them to the Chef Server.

    % cat environments/production.rb
    name "production"
    description "Systems in the Production Environment"

    % knife environment from file production.rb

License and Author
==================

Author:: Joshua Sierles <joshua@37signals.com>
Author:: Nathan Haneysmith <nathan@opscode.com>
Author:: Joshua Timberman <joshua@opscode.com>
Author:: Seth Chisamore <schisamo@opscode.com>
Author:: Tim Smith <tim.smith@webtrends.com>

Copyright 2009, 37signals
Copyright 2009-2011, Opscode, Inc
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
