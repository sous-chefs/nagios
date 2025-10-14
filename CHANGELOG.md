# nagios Cookbook CHANGELOG

This file is used to list changes made in each version of the nagios cookbook.

## Unreleased

Standardise files with files in sous-chefs/repo-management

Standardise files with files in sous-chefs/repo-management

Standardise files with files in sous-chefs/repo-management

## 12.1.3 - *2025-09-04*

Standardise files with files in sous-chefs/repo-management

## 12.1.2 - *2024-12-05*

## 12.1.1 - *2024-11-18*

Standardise files with files in sous-chefs/repo-management

Standardise files with files in sous-chefs/repo-management

## 12.1.0 - *2024-07-30*

Standardise files with files in sous-chefs/repo-management

- Add support for el9 based systems
- Centos stream 8 is EOL, switched to Centos stream 9

## 12.0.0 - *2024-07-02*

- Standardise files with files in sous-chefs/repo-management
- Update cookbook to use newer resource driven php cookbook
- Remove EOL platforms and other platform updates
- Add initial support for Ubuntu 24.04 (requires apache2 cookbook updates)

## 11.3.2 - *2024-05-02*

## 11.3.1 - *2024-05-02*

## 11.3.0 - *2024-05-01*

## 11.2.9 - *2024-04-29*

- Add FollowSymLinks option to cgi-bin directory on Apache. This prevents running into AH00670 errors if a Rewrite rule
  is used elsewhere in an apache configuration globally.

## 11.2.8 - *2024-04-29*

## 11.2.7 - *2024-04-29*

## 11.2.6 - *2023-12-21*

## 11.2.5 - *2023-10-31*

## 11.2.4 - *2023-09-28*

## 11.2.3 - *2023-09-04*

## 11.2.2 - *2023-07-10*

## 11.2.1 - *2023-05-17*

## 11.2.0 - *2023-04-25*

- Update to support apache2_service resource
- Install packages needed to run LDAP logins

## 11.1.12 - *2023-04-18*

- Standardise files with files in sous-chefs/repo-management

## 11.1.11 - *2023-04-05*

- Fix typos on oracle, redhat and centos

## 11.1.10 - *2023-04-04*

- Update lint-unit-workflow

## 11.1.9 - *2023-04-01*

- Standardise files with files in sous-chefs/repo-management

## 11.1.8 - *2023-04-01*

- Standardise files with files in sous-chefs/repo-management

## 11.1.7 - *2023-03-20*

- Standardise files with files in sous-chefs/repo-management

## 11.1.6 - *2023-03-13*

- Standardise files with files in sous-chefs/repo-management

## 11.1.5 - *2023-03-13*

- Standardise files with files in sous-chefs/repo-management

## 11.1.4 - *2023-02-27*

- Standardise files with files in sous-chefs/repo-management

## 11.1.3 - *2023-02-16*

- Standardise files with files in sous-chefs/repo-management

## 11.1.2 - *2023-02-14*

- Standardise files with files in sous-chefs/repo-management

## 11.1.1 - *2022-12-15*

- Standardise files with files in sous-chefs/repo-management

## 11.1.0 - *2022-08-10*

- Remove 5 second munging of command timeouts

## 11.0.0 - *2022-02-17*

- Remove delivery and move to calling RSpec directly via a reusable workflow
- Update tested platforms
- Enable `unified_mode` and require Chef >= 15.3
- Start nagios service
- Add support for Debian 11
- Use www-data user for nginx on Debian based systems

## 10.0.4 - *2022-02-08*

- Standardise files with files in sous-chefs/repo-management

## 10.0.3 - *2022-02-08*

- Remove delivery folder

## 10.0.2 - *2021-08-30*

- Standardise files with files in sous-chefs/repo-management

## 10.0.1 - *2021-06-01*

- Standardise files with files in sous-chefs/repo-management

## 10.0.0 - *2021-02-08*

- Sous Chefs Adoption
- Standardise files with files in sous-chefs/repo-management
- Cookstyle fixes
- Convert definitions to custom resources
- Update nginx recipe to use newer nginx cookbook
- Refactor and improve source installation
- Fix InSpec tests
- Use proper locations for zapping distribution configuration
- Various fixes for pagerduty recipe
- Switch to using `apache2_mod_php` resource
- Fix idempotency and other misc kitchen fixes

## 9.0.1 (2020-09-16)

- Cookstyle Bot Auto Corrections with Cookstyle 6.17.6

## 9.0.0 (2020-09-08)

- Use multipackage installs to speed up installs
- Pin the Apache2 requirement at < 7.0 since 7.0+ is not compatible with this cookbook
- Remove some legacy and broken attribute gating that would prevent all attributes from being set on RHEL systems
- Remove the check for the legacy Pagerduty attribute at `node['nagios']['pagerduty_key']`. This needs to be set at `node['nagios']['pagerduty']['key']` now
- Use `node['nagios']['server']['dependencies']` attribute to set the packages to be installed in the source recipe
- Add support for Debian 10
- Create helpers library to better manage platform configuration
- Remove support for Debian 9 and Amazon Linux 2
- Update source build to nagios-4.4.6
- Ensure we install the cgis when building from source
- Remove allowed-ips suite as that should be tested with ChefSpec
- Switch to using php cookbook and fix nginx cookbook version
- Set sensitive for debconf-set-selections execute resource
- Remove support for Apache 2.2 (resolves #556)

## 8.2.1 (2020-05-05)

- resolved cookstyle error: libraries/timeperiod.rb:72:15 convention: `Style/HashEachMethods`

## 8.2.0 (2019-31-01)

- Require Chef Infra Client 14.0+ and remove the need for the build-essential cookbook depenedency
- Fix hash has no keys method
- Simplify platform detection logic in the attributes file
- Migrate to Github Actions for testing
- Use the :immediately timing not :immediate in notifications

## 8.1.0 (May 8, 2018)

- Resolve incompatibilities with the latest PHP cookbook by installing php-gd
- Resolve multiple cookstyle warnings
- Use the build_essential resource instead of the build-essential cookbook so we can skip the cookbook entirely when on Chef 14
- Clarify in the readme that this cookbook requires RHEL 7+
- Skip definitions whose name starts with "!"
- Add a `node['nagios']['pagerduty']['proxy_url']` attribute

## 8.0.0 (19-09-2017)

- #522 Drop support for RHEL 5
- #531 Drop support for Fedora OSes
- #534 Drop support for CentOS 6, Fedora OS, FreeBSD
- #541 Require Chef 12.9+
- #538 Update documentation for large installation tweaks and remove old attribute
- #522 Resolve Foodcritic warnings, Chef 13 failures
- #524 Update metadata maintainer and repo urls (moved to Sous Chefs)
- #529 Allow SSL settings overrides
- #530 Nginx refactor
- #532 Update links to refer to Sous-Chefs org
- #534 Multiple testing related improvements (Clean up kitchen config; Test Chef 12 and Chef 13 but allow Chef 13 to fail until it's properly supported)
- #537 Update recipe name change in apache2 4.0 cookbook (`apache2::mod_php5` becomes `apache2::mod_php`)
- #539 Remove chat page
- #540 Misc clean up and CookStyle fixes
- #541 Fix OpenSuse support
- #542 Test Kitchen config updates
- #544 Require apache2 cookbook >= 4.0
- #549 Yank old bats/ServerSpec tests and unsupported platform testing
- #550 Fix tests to allow Chef 12 and Chef 13 to pass for now
- #552 Switch from `chef_nginx` back to `nginx`

## 7.2.7

- #479 Fix bug preventing Nagios upgrade from source
- #484 Fix #483, eventhandlers are now loaded before contacts
- #475 Make service groups do negation for removed hostgroups
- #481 Update lock file location for CentOS/Fedora
- #488 Fix rubocop warnings
- #497 Allow base authentication for listed IPs to be disabled
- #507 Minor fixes for README
- #508 Add descriptions to Pager Duty commands
- #510 Switch from nginx cookbook to chef_nginx cookbook
- #513 Fix rubocop warnings
- #516 Multiple improvements to align with other community cookbooks (Add delivery config; Add GitHub issue templates; Fix suite names for Test Kitchen in Travis; Fix CookStyle warnings; Update README content; Update kitchen-dokken config and use delivery local instead of rake)

## 7.2.6

- #445 Fixing escalation_periods
- #448 Fixing service escalations
- #459 Fixing undefined method `push'
- #453 Fixing nodes without any tags
- #443 Merging the timezone settings
- #450 Allowing default guest user
- #454 Adding inheritance modifiers
- #462 Adding Apache LDAP settings
- #463 Adding '*' and 'null' as options
- #470 Adding option for wrapper cookbooks
- #470 Adding result_limit to cgi.cfg

## 7.2.4

- #419 Fixing the nagios_interval logic and readme
- #421 Fixing loading of pagerduty databag contacts
- #430 Fixing loading of timeperiods out of databag with ducktyping
- #437 Fixing loading of unmanaged_host databag regards to environments
- #441 Enable setting of Fixnum's within nagios configuration attributes
- #426 Added command: service_notify_by_sms_email
- #435 Adding pagerduty.cgi and needed packages

## 7.2.2

- Fixing the apache mpm breaking on centos.

## 7.2.0

- Added centos 7.1 for testing.
- Added centos 5.11 for testing.
- Added test-kitchen tests.
- Added logic to exclude nodes based on tag.
- Including apache2::mpm_prefork for apache.
- Added the ability to specify command arguments within services.
- Added the ability to specify custom options on hosts, contacts and services.

## 7.1.8

- Fixing the unmanagedhosts databag filter on environment.
- Fixing the services databag filter on environment.
- Moving the LWRP's providers into definitions.
  This will remove some extra complexity and output will be
  much nicer and debugging will be easier during the chef-converge.

## 7.1.6

- Fixing the nagios resource provider delete action.
- Added option for custom apache auth based on attribute.
- Update cgi-path attibute on source install.
- Update on test-kitchen tests.
- Update on kitchen-vagrant version.

## 7.1.4

- AuthzLDAPAuthoritative is removed in Apache 2.4.
- Fixed the pagerduty config by using LWRP.
- Made test config os (in)dependent.
- Added zap for config file cleanup.
- Added encrypted user databag support.
- Added extra configuration tests.
- Added gitter badge.

## 7.1.2

- Fixed display of style sheets on Ubuntu 14.04+
- service_check_timeout_state config option is now only set on modern Nagios releases.  This broke Ubuntu 10.04/12.04 service startup
- Updated Test Kitchen release / added additional platforms for testing
- Fixed the attribute used to enable notifications in the Readme file
- Fixed loading of node['nagios']['host_name_attribute']
- Search queries in hostgroups data bag are now limited to the monitored environments if using node['nagios']['monitored_environments']

## 7.1.0

- Fixed class-type checking with duck-typing on update_options.
- Fixed host_name_attribute on nagios model.
- Moved all nagios configuration options within attributes.
- Moved all nagios configuration attributes into separate file.
- With the change above we might introduced some config problems.
  Please check your attributes when upgrading.
- Added extra kitchen serverspec tests.

## 7.0.8

- Fixed servicegroups members.
- Chaned the order of data bag loading (commands first).
- Cleanup of the internals of the nagios model.
- Added kitchen serverspec tests.

## 7.0.6

- Fixed data bag import.(#346)
- Fixed missing create method on Servicegroup object. (#348)
- Fixed update_dependency_members for depedency objects.

## 7.0.4

- Fixed the order for resource.cfg population to be correct.

## 7.0.2

- Fixed the hardcoded cgi-bin path in server source.
- Fixed contact_groups within load_default_config recipe.
- Removed dead code from timeperiod.rb library.
- Ignore timeperiods that don't comply.
- Making time formats less restrictive. (#336)
- Make yum-epel recipe include optional via attribute.
- Only allow_empty_hostgroup_assignment for Nagios versions >= 3.4.0

## 7.0.0

- Added providers for all nagios configuration objects.
- Added wiki pages explaining the providers.
- Added wiki pages explaining the databags.
- Updated chefspec (4.2.0)
- Please test this version before using it in production. Some logic and attributes have changes, so this might break your current setup.
- Allow defining parents in the unmanaged hosts data bag so you can build the host map.
- Setup Apache2 before trying to configure the webserver so paths will be created
- Installed EPEL on RHEL so package installs work
- Set the Apache log dir to that provided by Apache since the Nagios log dir is now locked down to just the nagios user / group
- Template the resource.cfg file on RHEL platforms to prevent check failures
- Fix cgi-bin page loads on RHEL systems
- Fix CSS files not loading on Debian based systems
- Updated Test Kitchen dependency to 1.3.1 from 1.2.1

## 6.1.0

- Fix missing CSS files on RHEL/Fedora package installs
- Ensure the source file for Nagios is always downloaded to work around corrupt partial downloads
- Fixed permissions being changed on the resource directory during each run on RHEL systems
- Remove support for SSL V2 / V3 (Apache2/NGINX) and add TLS 1.1 and 1.2 (NGINX)
- Cleaned up and removed duplicate code from the web server configuration
- Added the ability to tag nodes with an attribute that excludes them from the monitoring search.  See readme for details
- [BREAKING] The /nagios or /nagios3 URLs are no longer valid.  Nagios should be installed on the root of the webserver and this never entirely worked
- Updated Rubocop rules
- Fixed specs to run with Chefspec 4.X

## v6.0.4

- Fix normalized hostnames not normalizing the hostgroups
- Don't register the service templates so that Nagios will start properly
- Require Apache2 cookbook version 2.0 or greater due to breaking changes with how site.conf files are handled
- Added additional options for perfdata
- Added the ability to specify a URL to download patches that will be applied to the source install prior to compliation

## v6.0.2

- Remove .DS_Store files in the supermarket file that caused failures on older versions of Berkshelf

## v6.0.0

- [BREAKING] NRPE is no longer installed by the nagios cookbook.  This is handled by the NRPE cookbook.  Moving this logic allows for more fined grained control of how the two services are installed and configured
- [BREAKING] Previously the Nagios server was monitored out of the box using a NRPE check.  This is no longer the case since the cookbooks are split.  You'll need to add a services data bag to return this functionality
- [BREAKING] RHEL now defaults to installing via packages.  If you would like to continue installing via source make sure to set the installation_method attribute
- [BREAKING] `additional_contacts` attribute has been removed.  This was previously used for Pagerduty integration
- [BREAKING] Server setup is now handled in the nagios::default recipe vs. the nagios::server recipe.  You will need to update roles / nodes referencing the old recipe

- htpasswd file should be setup after Nagios has been installed to ensure the user has been created
- Ensure that the Linux hostgroup still gets created even if the Nagios server is the first to come up in the environment
- Correctly set the vname on RHEL/Fedora platforms for source/package installs
- Set resource_dir in nagios.cfg on RHEL platforms with a new attribute
- Create the archives dir in the log on source installs
- Properly create the Nagios user/group on source installs
- Properly set the path for the p1.pl file on RHEL platforms
- Ensure that the hostgroups array doesn't include duplicates in the even that an environment and role have the same name
- Only template nagios.cfg once
- Fix ocsp-command typo in nagios.cfg
- Fix bug that prevented Apache2 recipe from completing
- Readme cleanup
- Created a new users_helper library to abstract much of the Ruby logic for building user lists out of the recipe
- Avoid writing out empty comments in templates for data bag driven configs
- Add a full chefignore file to help with Berkshelf
- Better documented host_perfdata_command and service_perfdata_command in the README
- Add possibility to configure default_service with options process_perf_data & action_url
- Add possibility to configure default_host with options process_perf_data & action_url
- Allow freshness_threshold and active_checks_enabled to be specified in templates
- Added a generic service-template w/min req. params
- New attribute node['nagios']['monitored_environments'] for specifying multiple environments you'd like to monitor
- Allow using the exclusion hostgroup format used by Nagios when defining the hostgroup for a check
- Host templates can now be defined via a new host_templates data bag.
- Vagrantfile updated for Vagrant 1.5 format changes
- Updated Rubocop / Foodcritic / Chefspec / Berkshelf gems to the latest for Travis testing
- Updated Berkshelf file to the 3.0 format
- Updated Test Kitchen / Kitchen Vagrant gems to the latest for local testing
- Test Kitchen suite added for source installs
- Ubuntu 13.04 swapped for 14.04 in Test Kitchen
- Added a large number of data bags to be used by Test Kitchen to handle several scenarios
- Setup port forwarding in Test Kitchen so you can converge the nodes and load the Web UI
- Added additional Test Kitchen and Chef Spec tests

## v5.3.4

- Fixed two bugs that prevented Apache/NGINX web server setups from configuring correctly

## v5.3.2

- Remove a development file that was accidentally added to the community site release

## v5.3.0

- Directories for RHEL installations have been updated to use correct RHEL directories vs. Debian directories. You may need to override these directories with the existing directories to not break existing installations on RHEL. Proceed with caution.
- Cookbook no longer fails the run if a node has no roles
- Cookbook no longer fails if there are no users defined in the data bag
- Cookbook no longer fails if a node has no hostname
- Cookbook no longer fails if the node does not have a defined OS
- Fix incorrect Pagerduty key usage
- Allowed NRPE hosts were not being properly determined due to bad logic and a typo
- Improve Test-Kitchen support with newer RHEL point releases, Ubuntu 13.04, and Debian 6/7
- Simplified logic in web server detection for determining public domain and switches from symbols to strings throughout
- Support for Nagios host escalations via a new data bag.  See the readme for additional details
- New attribute node['nagios']['monitoring_interface'] to allow specifying a specific network interface's IP to monitor
- You can now define the values for execute_service_checks, accept_passive_service_checks, execute_host_checks, and accept_passive_host_checks via attributes
- You can now define the values for obsess_over_services and obsess_over_hosts settings via attributes

## v5.2.0

- [BREAKING] This release requires yum-epel, which requires the yum v3.0 cookbook. This may break other cookbooks in your environment
- [BREAKING] Change yum cookbook dependency to yum-epel dependecy as yum cookbook v3.0 removed epel repo setup functionality
- Several fixes to the Readme examples
- [BREAKING] Use the new monitoring-plugins.org address for the Nagios Plugins during source installs
- The version of apt defined in the Berksfile is no longer constrained
- Find all nodes by searching by node not hostname to workaround failures in ohai determining the hostname
- Allow defining of time periods via new data bag nagios_timeperiods.  See the Readme for additional details

## v5.1.0

- [COOK-3210] Contacts are now only written out if the contact has Nagios keys defined, which prevents e-mail-less contacts from being written out
- [COOK-4098] Fixed an incorrect example for using templates in the readme
- Fixed a typo in the servicedependencies.cfg.erb template that resulted in hostgroup_name always being blank
- The Yum cookbook dependency has been pinned to < 3.0 to prevent breakage when the 3.0 cookbook is released
- [COOK-2389] The logic used to determine what IP to identify the monitored host by has been moved into the default library to simplify the hosts.cfg.erb template
- A Vagrantfile has been added to allow for testing on Ubuntu 10.04/12.04 and CentOS 5.9/6.4 in multi-node setups
- Chef spec tests have been added for the server
- Gemfile updated to use Rubocop 0.15 and TestKitchen 1.0
- [COOK-3913]/[COOK-3914] Source based installations now use Nagios 3.5.1 and the Nagios Plugins 1.5.0

- The names of the various data bags used in the cookbook can now be controlled with new attributes found in the server.rb attribute file
- All configuration options in the cgi.cfg and nrpe.cfg files can now be controlled via attributes
- [COOK-3690] An intermediate SSL certificate can now be used on the web server as defined in the new attribute `ssl_cert_chain_file`
- [COOK-2732] A service can now be applied to multiple hostgroups via the data bag definition
- [COOK-3781] Service escalations can now be written using wildcards.  See the readme for an example of this feature.
- [COOK-3702] Multiple PagerDuty keys for different contacts can be defined via a new nagios_pagerduty data bag.  See the readme for more information on the new data bag and attributes for this feature.
- [COOK-3774]Services can be limited to run on nagios servers in specific chef environments by adding a new "activate_check_in_environment" key to the services data bag.  See the Services section of the readme for an example.
- [CHEF-4702] Chef solo users can now user solo-search for data bag searchd (<https://github.com/edelight/chef-solo-search>)

## v5.0.2

- [COOK-3777] - Update NRPE in nagios cookbook to 2.15
- [COOK-3021] - NRPE LWRP updates files every run
- Fixing up to pass rubocop

## v5.0.0

- [COOK-3778] - Fix missing customization points for Icinga
- [COOK-3731] - Remove range searches in Nagios cookbook that break chef-zero
- [COOK-3729] - Update Nagios Plugin download URL
- [COOK-3579] - Stop shipping icons files that arent used
- [COOK-3332] - Fix `nagios::client` failures on Chef Solo
- [COOK-3730] - Change the default authentication method
- [COOK-3696] - Sort hostgroups so they don't get updated on each run
- [COOK-3670] - Add Travis support
- [COOK-3583] - Update Nagios source to 3.5.1
- [COOK-3577] - Cleanup code style
- [COOK-3287] - Provide more customization points to make it possible to use Icinga
- [COOK-1725] - Add configurable notification options for `nagios::pagerduty`
- [COOK-3723] - Support regexp_matching in Nagios
- [COOK-3695] - Add more tunables for default host template

## v4.2.0

- [COOK-3445] - Allow setting service dependencies from data dags
- [COOK-3429] - Allow setting timezone from attribute
- [COOK-3422] - Enable large installation tweaks by attribute
- [COOK-3440] - Permit additional pagerduty-like integrations
- [COOK-3136] - Fix `nagios::client_source` under Gentoo
- [COOK-3111] - Add support for alternate users databag to Nagios cookbook
- [COOK-2891] - Improve RHEL 5 detection in Nagios cookbook to catch all versions
- [COOK-2721] - Add Chef Solo support
- [COOK-3405] - Fix NRPE source install on Ubuntu
- [COOK-3404] - Fix `htpasswd` file references (Chef 11 fix)
- [COOK-3282] - Use `host_name` attribute when used in conjunction with a search-defined hostgroup
- [COOK-3162] - Allow setting port
- [COOK-3140] - No longer import databag users even if they don't have an `htpasswd` value set
- [COOK-3068] - Use `nagios_conf` definition in `nagios::pagerduty`

## v4.1.4

- [COOK-3014]: Nagios cookbook imports data bag users even if they have action `:remove`
- [COOK-2826]: Allow Nagios cookbook to configure location of SSL files

## v4.1.2

- [COOK-2967]: nagios cookbook has foodcritic failure
- [COOK-2630]: Improvements to Readme and Services.cfg.erb template
- [COOK-2460]: create attribute for `allowed_hosts`

## v4.1.0

- [COOK-2257] - Nagios incorrectly tries to use cloud IPs due to a OHAI bug
- [COOK-2474] - hosts.cfg.erb assumes if nagios server node has the cloud attributes all nodes have the cloud attributes
- [COOK-1068] - Nagios::client should support CentOS/RHEL NRPE installs via package
- [COOK-2565] - nginx don't send `AUTH_USER` & `REMOTE_USER` to nagios
- [COOK-2546] - nrpe config files should not be world readable
- [COOK-2558] - Services that are attached to hostgroups created from the nagios_hostgroups databag are not created
- [COOK-2612] - Nagios can't start if search can't find hosts defined in nagios_hostgroups
- [COOK-2473] - Install Nagios 3.4.4 for source installs
- [COOK-2541] - Nagios cookbook should use node.roles instead of node.run_list.roles when calculating hostgroups
- [COOK-2543] - Adds the ability to normalize hostnames to lowercase
- [COOK-2450] - Add ability to define service groups through data bags.
- [COOK-2642] - With multiple nagios servers, they can't use NRPE to check each other
- [COOK-2613] - Install Nagios 3.5.0 when installing from source

## v4.0.0

This is a major release that refactors a significant amount of the service configuration to use data bags rather than hardcoding specific checks in the templates. The README describes how to create services via data bags.

The main incompatibility and breaking change is that the default services that are monitored by Nagios is reduced to only the "check-nagios" service. This means that existing installations will need to start converting checks over to the new data bag entries.

- [COOK-1553] - Nagios: check_nagios command does not work if Nagios is installed from source
- [COOK-1554] - Nagios: The nagios server should be added to all relevant host groups
- [COOK-1746] - nagios should provide more flexibility for server aliases
- [COOK-2006] - Extract default checks out of nagios
- [COOK-2129] - If a host is in the _default environment it should go into the default hostgroup
- [COOK-2130] - Chef needs to use the correct nagios plugin path on 64bit CentOS systems
- [COOK-2131] - gd development packages are not necessary for NRPE installs from source
- [COOK-2132] - Update NRPE installs to 2.14 from 2.13
- [COOK-2134] - Handle nagios-nrpe-server and nrpe names for NRPE in the init scripts and cookbook
- [COOK-2135] - Use with-nagios-user and group options source NRPE installs
- [COOK-2136] - Nagios will not pass config check when multiple machines in different domains have the same hostname
- [COOK-2150] - hostgroups data bag search doesn't respect the multi_environment_monitoring attribute
- [COOK-2186] - add service escalation to nagios
- [COOK-2188] - A notification interval of zero is valid but prohibited by the cookbook
- [COOK-2200] - Templates and Services from data bags don't specify intervals in the same way as the rest of the cookbook
- [COOK-2216] - Nagios cookbook readme needs improvement
- [COOK-2240] - Nagios server setup needs to gracefully fail when users data bag is not present
- [COOK-2241] - Stylesheets fail to load on a fresh Nagios install
- [COOK-2242] - Remove unused checks in the NRPE config file
- [COOK-2245] - nagios::server writes openid apache configs before including apache2::mod_auth_openid
- [COOK-2246] - Most of the commands in the Nagios cookbook don't work
- [COOK-2247] - nagios::client_source sets pkgs to a string, then tries to pkgs.each do {|pkg| package pkg }
- [COOK-2257] - Nagios incorrectly tries to use cloud IPs due to a OHAI bug
- [COOK-2275] - The Nagios3 download URL attribute is unused
- [COOK-2285] - Refactor data bag searches into library
- [COOK-2294] - Add cas authentication to nagios cookbook
- [COOK-2295] - nagios: chef tries to start nagios-nrpe-server on every run
- [COOK-2300] - You should be able to define a nagios_service into the "all" host group
- [COOK-2341] - pagerduty_nagios.pl URL changed
- [COOK-2350] - Nagios server fails to start when installed via source on Ubuntu/Debian
- [COOK-2369] - Add LDAP support in the nagios cookbook.
- [COOK-2374] - Setting an unmanaged host to a string returns 'no method error'
- [COOK-2375] - Allows adding a service that utilizes a pre-existing command
- [COOK-2433] - Nagios: ldap authentication needs to handle anonymous binding ldap servers

## v3.1.0

- [COOK-2032] - Use public IP address for inter-cloud checks and private for intra-cloud checks
- [COOK-2081] - add support for `notes_url` to `nagios_services` data bags

## v3.0.0

This is a major release due to some dramatic refactoring to the service check configuration which may not be compatible with existing implementations of this cookbook.

- [COOK-1544] - Nagios cookbook needs to support event handlers
- [COOK-1785] - Template causes service restart every time
- [COOK-1879] - Nagios: add configuration to automatically redirect `http://myserver/` to `http://myserver/nagios3/`
- [COOK-1880] - Extra attribute was left over after the `multi_environment_monitoring` update
- [COOK-1881] - Oracle should be added to the metadata for Nagios
- [COOK-1891] - README says to modify the nrpe.cfg template, but the cookbook exports a resource for nrpe checks.
- [COOK-1947] - Nagios: Pager duty portions of Nagios cookbook not using nagios user/group attributes
- [COOK-1949] - Nagios: A bad role on a node shouldn't cause the cookbook to fail
- [COOK-1950] - Nagios: Simplify hostgroup building and cookbook code
- [COOK-1995] - Nagios: Update source install to use Nagios 3.4.3 not 3.4.1
- [COOK-2005] - Remove unusable check commands from nagios
- [COOK-2031] - Adding templates as a data bag, extending service data bag to take arbitrary config items
- [COOK-2032] - Use public IP address for intra-cloud checks
- [COOK-2034] - Nagios cookbook calls search more often than necessary
- [COOK-2054] - Use service description in the nagios_services databag items
- [COOK-2061] - template.erb refers to a service variable when it should reference template.

## v2.0.0

- [COOK-1543] - Nagios cookbook needs to be able to monitor environments
- [COOK-1556] - Nagios: Add ability to define service template to be used in the `nagios_services` data bag
- [COOK-1618] - Users data bag group allowed to log into Nagios should be configurable
- [COOK-1696] - Nagios: Support defining non-Chef managed hosts via data bag items
- [COOK-1697] - nagios: Source installs should install the latest NRPE and Nagios plugins
- [COOK-1717] - Nagios: nagios server web page under Apache2 fails to load out of the box
- [COOK-1723] - Amazon missing as a supported OS in the Nagios metadata
- [COOK-1732] - `nagios::client_source` includes duplicate resources
- [COOK-1815] - Switch Nagios to use platform_family not platform
- [COOK-1816] - Nagios: mod ssl shouldn't get installed if SSL isn't being used
- [COOK-1887] - `value_for_platform_family` use in Nagios cookbook is broken

## v1.3.0

- [COOK-715] - don't source /etc/sysconfig/network on non-RHEL platforms
- [COOK-769] - don't use nagios specific values in users data bag items if they don't exist
- [COOK-1206] - add nginx support
- [COOK-1225] - corrected inconsistencies (mode, user/group, template headers)
- [COOK-1281] - add support for amazon linux
- [COOK-1365] - nagios_conf does not use nagios user/group attributes
- [COOK-1410] - remvoe deprecated package resource
- [COOK-1411] - Nagios server source installs should not necessarily install the NRPE client from source
- [COOK-1412] - Nagios installs from source do not install a mail client so notifications fail
- [COOK-1413] - install nagios 3.4.1 instead of 3.2.3
- [COOK-1518] - missing sysadmins variable in apache recipe
- [COOK-1541] - support environments that have windows systems
- [COOK-1542] - allow setting flap detection via attribute
- [COOK-1545] - add support for defining host groups using search in data bags
- [COOK-1553] - check_nagios command doesn't work from source install
- [COOK-1555] - include service template for monitoring logs
- [COOK-1557] - check-nagios command only works in environments with single nagios server
- [COOK-1587] - use default attributes instead of normal in cookbook attributes files

## V1.2.6

- [COOK-860] - set mail command with an attribute by platform

## v1.2.4

- [COOK-1119] - attributes for command_timeout / dont_blame_nrpe options
- [COOK-1120] - allow monitoring from servers in multiple chef_environments

## v1.2.2

- [COOK-991] - NRPE LWRP No Longer Requires a Template
- [COOK-955] - Nagios Service Checks Defined by Data Bags

## v1.2.0

- [COOK-837] - Adding a Recipe for PagerDuty integration
- [COOK-868] - use node, not @node in template
- [COOK-869] - corrected NRPE PID path
- [COOK-907] - LWRP for defining NRPE checks
- [COOK-917] - changes to `mod_auth_openid` module

## v1.0.4

- [COOK-838] - Add HTTPS Option to Nagios Cookbook

## v1.0.2

- [COOK-636] - Nagios server recipe attempts to start too soon
- [COOK-815] - Nagios Config Changes Kill Nagios If Config Goes Bad

## v1.0.0

- Use Chef 0.10's `node.chef_environment` instead of `node['app_environment']`.
- source installation support on both client and server sides
- initial RHEL/CentOS/Fedora support
