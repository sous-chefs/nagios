
# nagios_service 'system-high-load' do
#   options 'check_command'  => 'system-load!20,15,10!40,35,30',
#           'use'            => 'default-service',
#           'hostgroup_name' => 'high_load_servers'
# end

property :check_name, String, name_property: true
property :check_command, String
property :use, String
property :hostgroup_name, String
property :options, Hash
