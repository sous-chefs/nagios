# Limitations

## Platform Support

This cookbook keeps support for currently maintained platforms where Nagios can be installed from the distribution repositories or from Nagios Core source:

- AlmaLinux 8 and 9
- CentOS Stream 9
- Debian 12 and 13
- Fedora latest
- Oracle Linux 8 and 9
- Red Hat Enterprise Linux 8 and later
- Rocky Linux 8 and 9
- Ubuntu 22.04 and 24.04

Debian 11 and Ubuntu 20.04 are no longer listed because they are outside this cookbook's non-EOL support target for this migration.

## Package Installation

Debian and Ubuntu use the distribution Nagios packages by default. RHEL-family platforms can use EPEL-backed packages or source installation, depending on repository availability.

Set `install_yum_epel false` on `nagios_server` if your organization supplies Nagios packages from another repository.

## Source Installation

Source installation downloads Nagios Core from the configured source URL and compiles it locally. The default source URL points to the official Nagios Core GitHub release archive for the configured version.

Source installation requires compiler tooling, PHP support, GD libraries, and platform packages supplied by `nagios_server` defaults. Override `source_dependencies`, `php_gd_package`, or source properties when a platform repository differs from the defaults.

## Chef Server Search

The default server configuration searches Chef Infra Server for users and monitored nodes. Chef Solo does not support that search behavior. For Chef Solo, disable `load_default_config` and `load_databag_config`, then declare object resources directly.
