require 'chef/log'
require 'chef/search/query'

# Simplify access to list of all valid Nagios users
class NagiosUsers
  attr_accessor :users

  def initialize(node)
    @node = node
    @users = []

    user_databag = node['nagios']['users_databag'].to_sym
    group = node['nagios']['users_databag_group']

    if node['nagios']['server']['use_encrypted_data_bags']
      load_encrypted_databag(user_databag)
    else
      search_databag(user_databag, group)
    end
  end

  def return_user_contacts
    contacts = []
    # add base contacts from nagios_users data bag
    @users.each do |s|
      contacts << s['id']
    end
    contacts
  end

  private

  def fail_search(user_databag)
    Chef::Log.fatal("\"#{user_databag}\" databag could not be found.")
    raise "\"#{user_databag}\" databag could not be found."
  end

  def load_encrypted_databag(user_databag)
    data_bag(user_databag).each do |u, _|
      d = data_bag_item(user_databag, u)
      @users << d unless d['nagios'].nil? || d['nagios']['email'].nil?
    end
  rescue Net::HTTPServerException
    fail_search(user_databag)
  end

  def search_databag(user_databag, group)
    Chef::Search::Query.new.search(user_databag, "groups:#{group} NOT action:remove") do |d|
      @users << d unless d['nagios'].nil? || d['nagios']['email'].nil?
    end
  rescue Net::HTTPServerException
    fail_search(user_databag)
  end
end
