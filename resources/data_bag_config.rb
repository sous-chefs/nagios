# frozen_string_literal: true

provides :nagios_data_bag_config
unified_mode true

use '_partial/_settings'

action :create do
  nagios_bags = NagiosDataBags.new

  load_hostgroups(nagios_bags)
  load_services(nagios_bags)
  load_named_objects(nagios_bags, settings['contactgroups_databag'], 'contactgroup_name', :nagios_contactgroup)
  load_named_objects(nagios_bags, settings['eventhandlers_databag'], 'command_name', :nagios_command)
  load_named_objects(nagios_bags, settings['contacts_databag'], 'contact_name', :nagios_contact)
  load_named_objects(nagios_bags, settings['hostescalations_databag'], 'host_description', :nagios_hostescalation)
  load_hosttemplates(nagios_bags)
  load_named_objects(nagios_bags, settings['servicedependencies_databag'], 'service_description', :nagios_servicedependency)
  load_named_objects(nagios_bags, settings['serviceescalations_databag'], 'service_description', :nagios_serviceescalation)
  load_named_objects(nagios_bags, settings['servicegroups_databag'], 'servicegroup_name', :nagios_servicegroup)
  load_templates(nagios_bags)
  load_named_objects(nagios_bags, settings['timeperiods_databag'], 'timeperiod_name', :nagios_timeperiod)
  load_unmanaged_hosts(nagios_bags)
end

action_class do
  require_relative '../libraries/data_bag_helper'

  def settings
    new_resource.settings
  end

  def load_hostgroups(nagios_bags)
    nagios_bags.get(settings['hostgroups_databag']).each do |group|
      next if group['search_query'].nil?

      result = if settings['multi_environment_monitoring']
                 query_environments = settings['monitored_environments'].map { |environment| "chef_environment:#{environment}" }.join(' OR ')
                 search(:node, "(#{group['search_query']}) AND (#{query_environments})")
               else
                 search(:node, "#{group['search_query']} AND chef_environment:#{node.chef_environment}")
               end

      result.each do |search_node|
        ruby_block "push nagios hostgroup search node #{search_node.name}" do
          block do
            search_node.automatic_attrs['roles'] = [group['hostgroup_name']]
            Nagios.instance.push(search_node)
          end
        end
      end
    end
  end

  def load_services(nagios_bags)
    nagios_bags.get(settings['services_databag']).each do |item|
      next unless item['activate_check_in_environment'].nil? || item['activate_check_in_environment'].include?(node.chef_environment)

      name = item['service_description'] || item['id']
      check_command = name.downcase.start_with?('check_') ? name.downcase : "check_#{name.downcase}"
      command_name = item['check_command'].nil? ? check_command : item['check_command']
      service_name = name.downcase.start_with?('check_') ? name.gsub('check_', '') : name.downcase
      item['check_command'] = command_name

      nagios_command command_name do
        options item
      end

      nagios_service service_name do
        options item
      end
    end
  end

  def load_named_objects(nagios_bags, bag_name, name_key, resource_name)
    nagios_bags.get(bag_name).each do |item|
      name = item[name_key] || item['id']
      declare_resource(resource_name, name) do
        options item
      end
    end
  end

  def load_hosttemplates(nagios_bags)
    nagios_bags.get(settings['hosttemplates_databag']).each do |item|
      name = item['host_name'] || item['id']
      item['name'] = name if item['name'].nil?
      nagios_host name do
        options item
      end
    end
  end

  def load_templates(nagios_bags)
    nagios_bags.get(settings['templates_databag']).each do |item|
      name = item['name'] || item['id']
      item['name'] = name
      nagios_service name do
        options item
      end
    end
  end

  def load_unmanaged_hosts(nagios_bags)
    nagios_bags.get(settings['unmanagedhosts_databag']).each do |item|
      if settings['multi_environment_monitoring'].nil?
        next if item['environment'].nil? || item['environment'] != node.chef_environment
      else
        envs = settings['monitored_environments']
        next if item['environment'].nil? || !envs.include?(item['environment'])
      end

      name = item['host_name'] || item['id']
      nagios_host name do
        options item
      end
    end
  end
end
