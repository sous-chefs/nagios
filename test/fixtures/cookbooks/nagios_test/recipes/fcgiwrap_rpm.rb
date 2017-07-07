#
# Cookbook:: nagios_test
# Recipe:: fcgiwrap_rpm
#
# Copyright:: 2017, The Authors, All Rights Reserved.

if platform_family?('rhel', 'amazon')
  Chef::Log.info 'Build and install custom fcgiwrap RPM'

  user 'vagrant' do
    home '/home/vagrant'
  end

  include_recipe 'build-essential'
  include_recipe 'yum-epel'
  include_recipe 'fcgiwrap_rpm::default'

  package %w(createrepo)

  execute 'create_repo' do
    command 'createrepo .'
    cwd '/home/vagrant/rpmbuild/RPMS/x86_64'
    action :nothing
  end

  yum_repository 'local_fcgiwrap' do
    description 'Local repo for fcgiwarp RPM'
    baseurl 'file:///home/vagrant/rpmbuild/RPMS/$basearch/'
    enabled true
    gpgcheck false
    action :create
    notifies :run, 'execute[create_repo]', :before
  end

  package 'fcgiwrap' do
    flush_cache :before
  end

else
  Chef::Log.info 'Not a RHEL system, skipping'
end
