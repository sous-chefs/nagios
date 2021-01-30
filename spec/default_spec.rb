require 'spec_helper'

describe 'nagios::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(
      platform: 'ubuntu',
      version: '20.04',
      step_into: %w(nagios_conf nagios_timeperiod)
    ) do |_node, server|
      server.create_data_bag(
        'users', 'user1' => { 'id' => 'tsmith',
                              'groups' => ['sysadmin'],
                              'nagios' => {
                                'pager' => 'nagiosadmin_pager@example.com',
                                'email' => 'nagiosadmin@example.com',
                              },
                            },
                 'user2' => { 'id' => 'bsmith',
                              'groups' => ['users'],
                            })
    end.converge(described_recipe)
  end

  before do
    stub_command('dpkg -l nagios4').and_return(true)
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  it 'should create conf_dir' do
    expect(chef_run).to create_directory('/etc/nagios4')
  end

  it 'should template apache2 htpassword file with only admins' do
    expect(chef_run).to render_file('/etc/nagios4/htpasswd.users')
  end

  it 'should template contacts config with valid users' do
    expect(chef_run).to render_file('/etc/nagios4/conf.d/contacts.cfg').with_content('tsmith')
    expect(chef_run).not_to render_file('/etc/nagios4/conf.d/contacts.cfg').with_content('bsmith')
  end

  it do
    expect(chef_run).to create_nagios_conf('commands')
  end

  it do
    expect(chef_run).to create_template('/etc/nagios4/conf.d/timeperiods.cfg').with(
      variables: {}
    )
  end

  it 'should template nagios config files' do
    expect(chef_run).to render_file('/etc/nagios4/conf.d/timeperiods.cfg').with_content(/
define timeperiod {
  timeperiod_name  24x7
  alias            24 Hours A Day, 7 Days A Week
  sunday           00:00-24:00
  monday           00:00-24:00
  tuesday          00:00-24:00
  wednesday        00:00-24:00
  thursday         00:00-24:00
  friday           00:00-24:00
  saturday         00:00-24:00
}
/)
    expect(chef_run).to render_file('/etc/nagios4/conf.d/hosts.cfg').with_content(/
define host {
  use         server
  host_name   Fauxhai
  hostgroups  _default,linux
  address     10.0.0.2
}
/)
    expect(chef_run).to render_file('/etc/nagios4/conf.d/hostgroups.cfg').with_content(/
define hostgroup {
  hostgroup_name all
  alias all
  members \*
}

define hostgroup {
  hostgroup_name  _default
  members         Fauxhai
}

define hostgroup {
  hostgroup_name  linux
  members         Fauxhai
}
/)
    expect(chef_run).to render_file('/etc/nagios4/conf.d/servicegroups.cfg')
    expect(chef_run).to render_file('/etc/nagios4/conf.d/services.cfg')
    [
      %r{^main_config_file=/etc/nagios4/nagios.cfg$},
      %r{^physical_html_path=/usr/share/nagios4/htdocs$},
      %r{^url_html_path=/nagios4$},
      /^show_context_help=1$/,
      %r{^nagios_check_command=/usr/lib/nagios/plugins/check_nagios /var/cache/nagios4/status.dat 5 '/usr/sbin/nagios4'$},
      /^use_authentication=1$/,
      /^#default_user_name=guest$/,
      /^authorized_for_system_information=\*$/,
      /^authorized_for_configuration_information=\*$/,
      /^authorized_for_system_commands=\*$/,
      /^authorized_for_all_services=\*$/,
      /^authorized_for_all_hosts=\*$/,
      /^authorized_for_all_service_commands=\*$/,
      /^authorized_for_all_host_commands=\*$/,
      /^default_statusmap_layout=5$/,
      /^default_statuswrl_layout=4$/,
      %r{^ping_syntax=/bin/ping -n -U -c 5 \$HOSTADDRESS\$$},
      /^refresh_rate=90$/,
      /^result_limit=100$/,
      /^escape_html_tags=0$/,
      /^action_url_target=_blank$/,
      /^notes_url_target=_blank$/,
      /^lock_author_names=1$/,
    ].each do |line|
      expect(chef_run).to render_file('/etc/nagios4/cgi.cfg').with_content(line)
    end
    expect(chef_run).to render_file('/etc/nagios4/conf.d/templates.cfg')
    expect(chef_run).to render_file('/etc/nagios4/nagios.cfg').with_content(%r{
log_file=/var/log/nagios4/nagios.log
cfg_dir=/etc/nagios4/conf.d
object_cache_file=/var/cache/nagios4/objects.cache
precached_object_file=/var/cache/nagios4/objects.precache
resource_file=/etc/nagios4/resource.cfg
temp_file=/var/cache/nagios4/nagios.tmp
temp_path=/tmp
status_file=/var/cache/nagios4/status.dat
status_update_interval=10
nagios_user=nagios
nagios_group=nagios
enable_notifications=1
execute_service_checks=1
accept_passive_service_checks=1
execute_host_checks=1
accept_passive_host_checks=1
enable_event_handlers=1
log_rotation_method=d
log_archive_path=/var/log/nagios4/archives
check_external_commands=1
command_check_interval=-1
command_file=/var/lib/nagios4/rw/nagios.cmd
external_command_buffer_slots=4096
check_for_updates=0
lock_file=/var/run/nagios4/nagios4.pid
retain_state_information=1
state_retention_file=/var/lib/nagios4/retention.dat
retention_update_interval=60
use_retained_program_state=1
use_retained_scheduling_info=1
use_syslog=1
log_notifications=1
log_service_retries=1
log_host_retries=1
log_event_handlers=1
log_initial_states=0
log_external_commands=1
log_passive_checks=1
sleep_time=1
service_inter_check_delay_method=s
max_service_check_spread=5
service_interleave_factor=s
max_concurrent_checks=0
check_result_reaper_frequency=10
max_check_result_reaper_time=30
check_result_path=/var/lib/nagios4/spool/checkresults
max_check_result_file_age=3600
host_inter_check_delay_method=s
max_host_check_spread=5
interval_length=1
auto_reschedule_checks=0
auto_rescheduling_interval=30
auto_rescheduling_window=180
use_aggressive_host_checking=0
translate_passive_host_checks=0
passive_host_checks_are_soft=0
enable_predictive_host_dependency_checks=1
enable_predictive_service_dependency_checks=1
cached_host_check_horizon=15
cached_service_check_horizon=15
use_large_installation_tweaks=0
enable_environment_macros=1
enable_flap_detection=1
low_service_flap_threshold=5.0
high_service_flap_threshold=20.0
low_host_flap_threshold=5.0
high_host_flap_threshold=20.0
soft_state_dependencies=0
service_check_timeout=60
host_check_timeout=30
event_handler_timeout=30
notification_timeout=30
ocsp_timeout=5
ochp_timeout=5
perfdata_timeout=5
obsess_over_services=0
obsess_over_hosts=0
process_performance_data=0
check_for_orphaned_services=1
check_for_orphaned_hosts=1
check_service_freshness=1
service_freshness_check_interval=60
check_host_freshness=0
host_freshness_check_interval=60
additional_freshness_latency=15
enable_embedded_perl=1
use_embedded_perl_implicitly=1
date_format=iso8601
use_timezone=UTC
illegal_object_name_chars=`~!\$%\^&\*\|'"<>\?,\(\)=
illegal_macro_output_chars=`~\$&\|'"<>#
use_regexp_matching=0
use_true_regexp_matching=0
admin_email=root@localhost
admin_pager=root@localhost
event_broker_options=-1
retained_host_attribute_mask=0
retained_service_attribute_mask=0
retained_process_host_attribute_mask=0
retained_process_service_attribute_mask=0
retained_contact_host_attribute_mask=0
retained_contact_service_attribute_mask=0
daemon_dumps_core=0
debug_file=/var/lib/nagios4/nagios.debug
debug_level=0
debug_verbosity=1
max_debug_file_size=1000000
allow_empty_hostgroup_assignment=1
service_check_timeout_state=c
p1_file=/usr/lib/nagios4/p1.pl
})
    expect(chef_run).to render_file('/etc/nagios4/conf.d/servicedependencies.cfg')
    expect(chef_run).to render_file('/etc/nagios4/conf.d/commands.cfg')
  end
end
