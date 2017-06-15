# nagios_host 'generichosttemplate' do
#   options 'use'            => 'server',
#           'name'           => 'generichosttemplate',
#           'register'       => 0,
#           'check_interval' => 10,
#           'event_handler'  => 'my-event-handler-command'
# end


property :host_name, String, name_property: true
property :use, String
property :register, Integer, equal_to %w(0 1)
property :check_interval, Integer
property :event_handler, String
property :options, Hash

action :create do

end

action :delete do

end
