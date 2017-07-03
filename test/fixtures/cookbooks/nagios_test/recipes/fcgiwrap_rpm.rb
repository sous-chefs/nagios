#
# Cookbook:: nagios_test
# Recipe:: fcgiwrap_rpm
#
# Copyright:: 2017, The Authors, All Rights Reserved.

if %w(rhel).include?(node['platform_family'])
  Chef::Log.info 'Build and install custom fcgiwrap RPM'

  package %w(createrepo) 
  include_recipe 'build-essential'
  include_recipe 'fcgiwrap_rpm::default'

  execute 'create_repo' do
    command 'createrepo .'
    cwd '/home/vagrant/rpmbuild/RPMS/x86_64'
    action :nothing
  end

  cookbook_file '/etc/yum.repos.d/local.repo' do
    notifies :run, 'execute[create_repo]', :before
  end

else
  Chef::Log.info 'Not a RHEL system, skipping'
end
