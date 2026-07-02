# frozen_string_literal: true

name 'nagios'

default_source :supermarket

run_list 'recipe[test::policyfile_monitoring_role]', 'recipe[test::default]'

named_run_list :default, 'recipe[test::policyfile_monitoring_role]', 'recipe[test::default]'
named_run_list :ldap, 'recipe[test::policyfile_monitoring_role]', 'recipe[test::server_package_ldap]'
named_run_list :source, 'recipe[test::policyfile_monitoring_role]', 'recipe[test::server_source]'
named_run_list :swappable_config, 'recipe[test::policyfile_monitoring_role]', 'recipe[test::swappable_config]'
named_run_list :pagerduty, 'recipe[test::policyfile_monitoring_role]', 'recipe[test::pagerduty]'
named_run_list :nginx, 'recipe[test::policyfile_monitoring_role]', 'recipe[test::nginx]'

cookbook 'nagios', path: '.'
cookbook 'test', path: 'test/cookbooks/test'
