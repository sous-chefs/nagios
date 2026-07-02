# frozen_string_literal: true

# Policyfiles cannot include Chef roles in named run lists, but these suites
# still exercise the old monitoring role's override attributes and role group.
node.override['nagios']['exclude_tag_host'] = %w(foo)
node.override['nagios']['host_name_attribute'] = 'custom_host_name_attribute'
node.override['nagios']['multi_environment_monitoring'] = true
node.override['nagios']['monitored_environments'] = %w(_default)
node.override['nagios']['conf']['use_syslog'] = 0
node.override['nagios']['conf']['host_perfdata_command'] = %w(command_a command_b)
node.override['nagios']['conf']['query_socket'] = nil

node.automatic['roles'] = Array(node['roles']) | %w(monitoring)
