action :create do
  o = Nagios::Command.create(params[:name])
  o.import(params[:options])
end

action :delete do
  Nagios.instance.delete('command', params[:name])
end


# nagios_command 'system-load' do
#   options 'command_line' => '$USER1$/check_load -w $ARG1$ -c $ARG2$'
# end

property :name, String, name_property: true
property :options, Hash, required: true

action :create do
  
end
