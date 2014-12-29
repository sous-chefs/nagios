require_relative 'nagios_base'

class Nagios
  class Hostescalation < Nagios::Base

    attr_reader   :host_description,
                  :host_name,
                  :hostgroup_name,
                  :contacts,
                  :contact_groups,
                  :escalation_period

    attr_accessor :first_notification,
                  :last_notification,
                  :notification_interval,
                  :escalation_options

    def initialize(name)
      @host_description = name
      @name             = name
      @contacts         = {}
      @contact_groups   = {}
      @host_name        = {}
      @hostgroup_name   = {}
      @register         = 0
    end

    def definition
      configured = get_configured_options
      (['define hostescalation{'] + get_definition_options(configured) + ['}']).join("\n")
    end

    def contacts
      (@contacts.map {|k,v| v.id}).join(',')
    end

    def contact_groups
      (@contact_groups.map {|k,v| v.id}).join(',')
    end

    def host_name
      (@host_name.map {|k,v| v.id}).join(',')
    end

    def hostgroup_name
      (@hostgroup_name.map {|k,v| v.id}).join(',')
    end

    def id
      self.host_description
    end

    def import_hash(hash)
      update_options(hash)
      update_members(hash, 'contacts', Nagios::Contact)
      update_members(hash, 'contact_groups', Nagios::Contactgroup)
      update_members(hash, 'host_name', Nagios::Host)
      update_members(hash, 'hostgroup_name', Nagios::Hostgroup)
    end

    def push(obj)
      case obj
      when Nagios::Host
        push_object(obj, @host_name)
      when Nagios::Hostgroup
        push_object(obj, @hostgroup_name)
      when Nagios::Contact
        push_object(obj, @contacts)
      when Nagios::Contactgroup
        push_object(obj, @contact_groups)
      when Nagios::Timeperiod
        @escalation_period = obj    
      end
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Hostescalation.new(name))
    end

    def to_s
      self.host_description
    end

    # check the integer options
    # default = nil

    def first_notification=(int)
      @first_notification = check_integer(int)
    end

    def last_notification=(int)
      @last_notification = check_integer(int)
    end

    def notification_interval=(int)
      @notification_interval = check_integer(int)
    end

    # check other options

    def escalation_options=(arg)
      @escalation_options = check_state_options(arg, ['d','u','r'], 'escalation_options')
    end

    private

    def config_options
      {
        'name'                  => 'name',
        'use'                   => 'use',
        'host_description'      => nil,
        'contacts'              => 'contacts',
        'contact_groups'        => 'contact_groups',
        'escalation_period'     => 'escalation_period',
        'host_name'             => 'host_name',
        'hostgroup_name'        => 'hostgroup_name',
        'escalation_options'    => 'escalation_options',
        'first_notification'    => 'first_notification', 
        'last_notification'     => 'last_notification',
        'notification_interval' => 'notification_interval',
        'register'              => 'register' 
      }
    end

    def merge_members(obj)
      obj.contacts.each { |m| self.push(m) }
      obj.host_name.each { |m| self.push(m) }
      obj.contact_groups.each { |m| self.push(m) }
      obj.hostgroup_name.each { |m| self.push(m) }
    end

  end
end
