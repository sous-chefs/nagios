define :nagios_command do
  params[:action] ||= :create
  params[:options] ||= {}

  if nagios_action_create?(params[:action])
    o = Nagios::Command.create(params[:name])
    o.import(params[:options])
  end

  if nagios_action_delete?(params[:action])
    Nagios.instance.delete('command', params[:name])
  end
end



# nagios_command 'system-load' do
#   options 'command_line' => '$USER1$/check_load -w $ARG1$ -c $ARG2$'
# end

property :options, Hash, required: true

action :create do

end
