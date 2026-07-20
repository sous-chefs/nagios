# Limitations

## Package Availability

### APT (Debian and Ubuntu)

* Debian 12 provides Nagios 4.4.6 packages for amd64, arm64, armel, armhf, i386, mips64el,
  mipsel, ppc64el, and s390x.
* Debian 13 provides Nagios 4.4.6 packages for amd64, arm64, armel, armhf, i386, ppc64el,
  riscv64, and s390x.
* Ubuntu 22.04 provides Nagios 4.4.6 packages through the Universe repository.
* Ubuntu 24.04 provides Nagios 4.4.6 packages through the Universe repository for amd64, arm64,
  armhf, ppc64el, riscv64, and s390x.

### DNF/YUM (RHEL family and Fedora)

* EPEL 8 provides Nagios 4.4.14 packages.
* EPEL 9 provides Nagios 4.4.14 packages.
* Fedora 43 and 44 provide Nagios 4.5 packages.
* RHEL-compatible package installation requires EPEL or another repository that supplies the
  `nagios` and `nagios-plugins-nrpe` packages.
* This cookbook manages EPEL through the `yum_epel` custom resource. The `yum-epel` cookbook no
  longer provides a default recipe.

## Architecture Limitations

* Distribution package architectures vary by release. Package installation is limited to the
  architectures published by the selected distribution repository.
* Nagios Core can be compiled from source on other Linux architectures when a compatible C
  compiler and the required development libraries are available.

## Source/Compiled Installation

Nagios Core supports source installation on Linux. The web interface requires a web server, PHP,
and GD development libraries in addition to a C compiler and build tooling.

* Debian: build-essential, libssl-dev, libgdchart-gd2-xpm-dev, bsd-mailx, tar, and unzip.
* RHEL/Fedora: build tools, openssl-devel, gd-devel, tar, and unzip.

The source URL, version, checksum, patches, dependencies, and extra build commands are configurable
properties on `nagios_server`.

## Supported Platform Lifecycle

The cookbook tests maintained releases in its Kitchen matrix:

* AlmaLinux 8 and 9
* CentOS Stream 9
* Debian 12 and 13
* Fedora latest
* Oracle Linux 8 and 9
* Rocky Linux 8 and 9
* Ubuntu 22.04 and 24.04

Debian 12 remains in Debian LTS, and the Enterprise Linux 8 derivatives remain in security support.
CentOS Stream 9, Debian 13, Fedora 44, Enterprise Linux 9, Ubuntu 22.04, and Ubuntu 24.04 are within
their published support periods as of July 2026.

## Known Issues

* Distribution packages may lag the latest Nagios Core release. Use source installation when a
  newer Nagios release is required.
* Package names, paths, PHP versions, and service names differ between Debian-family and
  RHEL-family platforms.
* Chef Solo cannot perform the Chef Infra Server searches used by the default and data bag
  configuration resources. Disable those loaders and declare Nagios object resources directly.
