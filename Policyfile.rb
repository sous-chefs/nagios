# frozen_string_literal: true

name 'nagios'

default_source :supermarket

run_list 'recipe[test::default]'

named_run_list :default, 'recipe[test::default]'
named_run_list :ldap, 'recipe[test::server_package_ldap]'
named_run_list :source, 'recipe[test::server_source]'
named_run_list :swappable_config, 'recipe[test::swappable_config]'
named_run_list :pagerduty, 'recipe[test::pagerduty]'
named_run_list :nginx, 'recipe[test::nginx]'

cookbook 'nagios', path: '.'
cookbook 'test', path: 'test/cookbooks/test'
