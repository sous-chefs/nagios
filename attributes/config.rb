#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Attributes:: config
#
# Copyright 2015, Sander Botman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# This class holds all nagios configuration options.
#

default['nagios']['conf']['log_file']                                    = "#{node['nagios']['log_dir']}/#{node['nagios']['server']['name']}.log"
default['nagios']['conf']['cfg_dir']                                     = node['nagios']['config_dir']
default['nagios']['conf']['object_cache_file']                           = "#{node['nagios']['cache_dir']}/objects.cache"
default['nagios']['conf']['precached_object_file']                       = "#{node['nagios']['cache_dir']}/objects.precache"
default['nagios']['conf']['resource_file']                               = "#{node['nagios']['resource_dir']}/resource.cfg"
default['nagios']['conf']['temp_file']                                   = "#{node['nagios']['cache_dir']}/#{node['nagios']['server']['name']}.tmp"
default['nagios']['conf']['temp_path']                                   = '/tmp'
default['nagios']['conf']['status_file']                                 = "#{node['nagios']['cache_dir']}/status.dat"
default['nagios']['conf']['status_update_interval']                      = '10'
default['nagios']['conf']['nagios_user']                                 = node['nagios']['user']
default['nagios']['conf']['nagios_group']                                = node['nagios']['group']
default['nagios']['conf']['enable_notifications']                        = '1'
default['nagios']['conf']['execute_service_checks']                      = '1'
default['nagios']['conf']['accept_passive_service_checks']               = '1'
default['nagios']['conf']['execute_host_checks']                         = '1'
default['nagios']['conf']['accept_passive_host_checks']                  = '1'
default['nagios']['conf']['enable_event_handlers']                       = '1'
default['nagios']['conf']['log_rotation_method']                         = 'd'
default['nagios']['conf']['log_archive_path']                            = "#{node['nagios']['log_dir']}/archives"
default['nagios']['conf']['check_external_commands']                     = '1'
default['nagios']['conf']['command_check_interval']                      = '-1'
default['nagios']['conf']['command_file']                                = "#{node['nagios']['state_dir']}/rw/#{node['nagios']['server']['name']}.cmd"
default['nagios']['conf']['external_command_buffer_slots']               = '4096' # Deprecated, Starting with Nagios Core 4, this variable has no effect.
default['nagios']['conf']['check_for_updates']                           = '0'
default['nagios']['conf']['lock_file']                                   = "#{node['nagios']['run_dir']}/#{node['nagios']['server']['vname']}.pid"
default['nagios']['conf']['retain_state_information']                    = '1'
default['nagios']['conf']['state_retention_file']                        = "#{node['nagios']['state_dir']}/retention.dat"
default['nagios']['conf']['retention_update_interval']                   = '60'
default['nagios']['conf']['use_retained_program_state']                  = '1'
default['nagios']['conf']['use_retained_scheduling_info']                = '1'
default['nagios']['conf']['use_syslog']                                  = '1'
default['nagios']['conf']['log_notifications']                           = '1'
default['nagios']['conf']['log_service_retries']                         = '1'
default['nagios']['conf']['log_host_retries']                            = '1'
default['nagios']['conf']['log_event_handlers']                          = '1'
default['nagios']['conf']['log_initial_states']                          = '0'
default['nagios']['conf']['log_external_commands']                       = '1'
default['nagios']['conf']['log_passive_checks']                          = '1'
default['nagios']['conf']['sleep_time']                                  = '1' # Deprecated, Starting with Nagios Core 4, this variable has no effect.
default['nagios']['conf']['service_inter_check_delay_method']            = 's'
default['nagios']['conf']['max_service_check_spread']                    = '5'
default['nagios']['conf']['service_interleave_factor']                   = 's'
default['nagios']['conf']['max_concurrent_checks']                       = '0'
default['nagios']['conf']['check_result_reaper_frequency']               = '10'
default['nagios']['conf']['max_check_result_reaper_time']                = '30'
default['nagios']['conf']['check_result_path']                           =
  if node['platform'] == 'centos' && node['platform_version'].to_i >= 7
    "#{node['nagios']['home']}/checkresults"
  else
    "#{node['nagios']['state_dir']}/spool/checkresults"
  end
default['nagios']['conf']['max_check_result_file_age']                   = '3600'
default['nagios']['conf']['host_inter_check_delay_method']               = 's'
default['nagios']['conf']['max_host_check_spread']                       = '5'
default['nagios']['conf']['interval_length']                             = '1'
default['nagios']['conf']['auto_reschedule_checks']                      = '0'
default['nagios']['conf']['auto_rescheduling_interval']                  = '30'
default['nagios']['conf']['auto_rescheduling_window']                    = '180'
default['nagios']['conf']['use_aggressive_host_checking']                = '0'
default['nagios']['conf']['translate_passive_host_checks']               = '0'
default['nagios']['conf']['passive_host_checks_are_soft']                = '0'
default['nagios']['conf']['enable_predictive_host_dependency_checks']    = '1'
default['nagios']['conf']['enable_predictive_service_dependency_checks'] = '1'
default['nagios']['conf']['cached_host_check_horizon']                   = '15'
default['nagios']['conf']['cached_service_check_horizon']                = '15'
default['nagios']['conf']['use_large_installation_tweaks']               = '0'
default['nagios']['conf']['enable_environment_macros']                   = '1'
default['nagios']['conf']['enable_flap_detection']                       = '1'
default['nagios']['conf']['low_service_flap_threshold']                  = '5.0'
default['nagios']['conf']['high_service_flap_threshold']                 = '20.0'
default['nagios']['conf']['low_host_flap_threshold']                     = '5.0'
default['nagios']['conf']['high_host_flap_threshold']                    = '20.0'
default['nagios']['conf']['soft_state_dependencies']                     = '0'
default['nagios']['conf']['service_check_timeout']                       = '60'
default['nagios']['conf']['host_check_timeout']                          = '30'
default['nagios']['conf']['event_handler_timeout']                       = '30'
default['nagios']['conf']['notification_timeout']                        = '30'
default['nagios']['conf']['ocsp_timeout']                                = '5'
default['nagios']['conf']['ochp_timeout']                                = '5'
default['nagios']['conf']['perfdata_timeout']                            = '5'
default['nagios']['conf']['obsess_over_services']                        = '0'
default['nagios']['conf']['obsess_over_hosts']                           = '0'
default['nagios']['conf']['process_performance_data']                    = '0'
default['nagios']['conf']['check_for_orphaned_services']                 = '1'
default['nagios']['conf']['check_for_orphaned_hosts']                    = '1'
default['nagios']['conf']['check_service_freshness']                     = '1'
default['nagios']['conf']['service_freshness_check_interval']            = '60'
default['nagios']['conf']['check_host_freshness']                        = '0'
default['nagios']['conf']['host_freshness_check_interval']               = '60'
default['nagios']['conf']['additional_freshness_latency']                = '15'
default['nagios']['conf']['enable_embedded_perl']                        = '1'
default['nagios']['conf']['use_embedded_perl_implicitly']                = '1'
default['nagios']['conf']['date_format']                                 = 'iso8601'
default['nagios']['conf']['use_timezone']                                = 'UTC'
default['nagios']['conf']['illegal_object_name_chars']                   = '`~!$%^&*|\'"<>?,()='
default['nagios']['conf']['illegal_macro_output_chars']                  = '`~$&|\'"<>#'
default['nagios']['conf']['use_regexp_matching']                         = '0'
default['nagios']['conf']['use_true_regexp_matching']                    = '0'
default['nagios']['conf']['admin_email']                                 = node['nagios']['sysadmin_email']
default['nagios']['conf']['admin_pager']                                 = node['nagios']['sysadmin_sms_email']
default['nagios']['conf']['event_broker_options']                        = '-1'
default['nagios']['conf']['retained_host_attribute_mask']                = '0'
default['nagios']['conf']['retained_service_attribute_mask']             = '0'
default['nagios']['conf']['retained_process_host_attribute_mask']        = '0'
default['nagios']['conf']['retained_process_service_attribute_mask']     = '0'
default['nagios']['conf']['retained_contact_host_attribute_mask']        = '0'
default['nagios']['conf']['retained_contact_service_attribute_mask']     = '0'
default['nagios']['conf']['daemon_dumps_core']                           = '0'
default['nagios']['conf']['debug_file']                                  = "#{node['nagios']['state_dir']}/#{node['nagios']['server']['name']}.debug"
default['nagios']['conf']['debug_level']                                 = '0'
default['nagios']['conf']['debug_verbosity']                             = '1'
default['nagios']['conf']['max_debug_file_size']                         = '1000000'

default['nagios']['conf']['cfg_file']                                    = nil
default['nagios']['conf']['query_socket']                                = nil
default['nagios']['conf']['check_workers']                               = nil
default['nagios']['conf']['log_current_states']                          = nil
default['nagios']['conf']['bare_update_check']                           = nil
default['nagios']['conf']['global_host_event_handler']                   = nil
default['nagios']['conf']['global_service_event_handler']                = nil
default['nagios']['conf']['free_child_process_memory']                   = nil
default['nagios']['conf']['ocsp_command']                                = nil
default['nagios']['conf']['ochp_command']                                = nil
default['nagios']['conf']['host_perfdata_command']                       = nil
default['nagios']['conf']['service_perfdata_command']                    = nil
default['nagios']['conf']['host_perfdata_file']                          = nil
default['nagios']['conf']['service_perfdata_file']                       = nil
default['nagios']['conf']['host_perfdata_file_template']                 = nil
default['nagios']['conf']['service_perfdata_file_template']              = nil
default['nagios']['conf']['host_perfdata_file_mode']                     = nil
default['nagios']['conf']['service_perfdata_file_mode']                  = nil
default['nagios']['conf']['host_perfdata_file_processing_interval']      = nil
default['nagios']['conf']['service_perfdata_file_processing_interval']   = nil
default['nagios']['conf']['host_perfdata_file_processing_command']       = nil
default['nagios']['conf']['service_perfdata_file_processing_command']    = nil
default['nagios']['conf']['broker_module']                               = nil

if node['nagios']['server']['install_method'] == 'source' ||
   (node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 6) ||
   (node['platform'] == 'debian' && node['platform_version'].to_i >= 7) ||
   (node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 14.04)
  default['nagios']['conf']['allow_empty_hostgroup_assignment'] = '1'
  default['nagios']['conf']['service_check_timeout_state']      = 'c'
end

case node['platform_family']
when 'debian'
  default['nagios']['conf']['p1_file'] = "#{node['nagios']['home']}/p1.pl"
when 'rhel', 'amazon'
  default['nagios']['conf']['p1_file'] = '/usr/sbin/p1.pl'
else
  default['nagios']['conf']['p1_file'] = "#{node['nagios']['home']}/p1.pl"
end
