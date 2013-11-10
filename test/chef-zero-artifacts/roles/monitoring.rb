name 'monitoring'
description 'Monitoring Server'
run_list(
  'recipe[apt::default]',
  'recipe[nagios::server]'
 )
