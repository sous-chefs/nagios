include NagiosCookbook::Helpers
unified_mode true

action :install do
  package nagios_packages

  directory nagios_config_dir do
    recursive true
  end
end

action_class do
  include NagiosCookbook::Helpers
end
