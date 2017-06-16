# action :create do
#   o = Nagios::Contact.create(params[:name])
#   o.import(params[:options])
# end
#
# action :delete do
#     Nagios.instance.delete('contact', params[:name])
# end


# nagios_contact 'sander botman' do
#   options 'use'            => 'default-contact',
#           'alias'          => 'Nagios Noob',
#           'pager'          => '+31651425985',
#           'email'          => 'sbotman@schubergphilis.com',
#           '_my_custom_key' => 'custom_value'
# end

property :contact_name, String, name_property: true
property :use, String
property :alias, String
property :pager, String
property :email, String
property :options, String

action :create do

end

action :delete do
  
end
