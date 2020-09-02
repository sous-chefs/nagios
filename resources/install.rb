include NagiosCookbook::Helpers

property :packages, [String, Array],
         default: lazy { nagios_packages },
         description: 'List of packages to install for nagios'

property :config_dir, String,
         default: lazy { nagios_config_dir },
         description: 'Default location for the nagios configuration files'

property :check_result_path, String,
         default: lazy { nagios_check_result_path },
         description: 'Directory Nagios will use to temporarily store host and service check results before they are processed'

property :cache_dir, String,
         default: lazy { nagios_cache_dir },
         description: 'Directory Nagios will use for caching files'

property :log_dir, String,
         default: lazy { nagios_log_dir },
         description: 'Directory Nagios will use for logging files'

property :run_dir, String,
         default: lazy { nagios_run_dir },
         description: 'Directory Nagios will use for run state files'

property :archives_dir, String,
         default: lazy { "#{nagios_log_dir}/archives" },
         description: 'Directory Nagios will use for storing archive files'

action :install do
  include_recipe 'yum-epel' if platform_family?('rhel', 'amazon')

  package new_resource.packages do
    notifies :delete, 'directory[purge distro conf.d]', :immediately
  end

  directory 'purge distro conf.d' do
    path "#{apache_dir}/conf.d"
    recursive true
    action :nothing
  end

  directory new_resource.config_dir do
    recursive true
  end

  [
    new_resource.check_result_path,
    new_resource.cache_dir,
    new_resource.log_dir,
    new_resource.run_dir,
    new_resource.archives_dir,
    "/usr/lib/#{nagios_vname}",
  ].each do |nagios_dir|
    directory nagios_dir do
      owner 'nagios'
      group 'nagios'
      recursive true
    end
  end
end

action_class do
  include NagiosCookbook::Helpers
  include Apache2::Cookbook::Helpers
end
