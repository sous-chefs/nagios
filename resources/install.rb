property :server_packages, Array, default: lazy {
  case node['platform_family']
  when 'rhel', 'fedora', 'amazon'
    %w(nagios nagios-plugins-nrpe)
  else
    %w(nagios3 nagios-nrpe-plugin nagios-images)
  end
}
property :source_packages, Array, default: lazy {
  value_for_platform_family(
    %w( rhel fedora amazon) => %w( openssl-devel gd-devel tar ),
    'debian' => %w( libssl-dev libgd2-xpm-dev bsd-mailx tar ),
    'default' => %w( libssl-dev libgd2-xpm-dev bsd-mailx tar )
  )
}
# nagios server name and webserver vname.  this can be changed to allow for the installation of icinga
property :server_name, String, default: 'nagios'
property :vhost_name, String, default: 'nagios'
property :nagios_user, String, default: 'nagios'
property :nagios_group, String, default: 'nagios'
property :web_server_user, String, required: true
property :source_url, String, default: 'https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.4.tar.gz'
property :source_checksum, String, default: 'b0055c475683ce50d77b1536ff0cec9abf89139adecf771601fa021ef9a20b70'
property :server_src_dir, String, default: lazy {
  new_resource.source_url.split('/')[-1].chomp('.tar.gz')
}
property :patches, Array
property :patch_url, String

node['nagios']['conf_dir']
property :conf_dir, String, default:

default_action :package_install

action :package_install do
  if  node['platform_family'] == 'debian'
    # Nagios package requires to enter the admin password
    # We generate it randomly as it's overwritten later in the config templates
    random_initial_password = rand(36**16).to_s(36)

    %w(adminpassword adminpassword-repeat).each do |setting|
      execute "debconf-set-selections::#{new_resource.vhost_name}-cgi::#{new_resource.vhost_name}/#{setting}" do
        command "echo #{new_resource.vhost_name}-cgi #{new_resource.vhost_name}/#{setting} password #{random_initial_password} | debconf-set-selections"
        not_if "dpkg -l #{new_resource.vhost_name}"
      end
    end
  end

  include_recipe 'yum-epel' if node['platform_family'] == 'rhel'

  package new_resource.server_packages
end

action :source_install do
  # Package pre-reqs
  include_recipe 'build-essential'
  include_recipe 'php::default'
  include_recipe 'php::module_gd'

  package new_resource.source_packages

  user new_resource.nagios_user

  web_srv = node['nagios']['server']['web_server']

  group new_resource.nagios_group do
    members [
      new_resource.nagios_user,
      new_resource.web_server_user,
    ]
    action :create
  end

  remote_file "#{Chef::Config[:file_cache_path]}/nagios_core.tar.gz" do
    source node['nagios']['server']['url']
    checksum node['nagios']['server']['checksum']
  end

  new_resource.patches.each do |patch|
    remote_file "#{Chef::Config[:file_cache_path]}/#{patch}" do
      source "#{new_resource.patch_url}/#{patch}"
    end
  end

  execute 'extract-nagios' do
    cwd Chef::Config[:file_cache_path]
    command 'tar zxvf nagios_core.tar.gz'
    not_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/#{new_resource.server_src_dir}") }
  end

  new_resource.patches.each do |patch|
    bash "patch-#{patch}" do
      cwd Chef::Config[:file_cache_path]
      code <<-EOF
        cd #{new_resource.server_src_dir}
        patch -p1 --forward --silent --dry-run < '#{Chef::Config[:file_cache_path]}/#{patch}' >/dev/null
        if [ $? -eq 0 ]; then
          patch -p1 --forward < '#{Chef::Config[:file_cache_path]}/#{patch}'
        else
          exit 0
        fi
      EOF
      action :nothing
      subscribes :run, 'execute[extract-nagios]', :immediately
    end
  end

  bash 'compile-nagios' do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      cd #{new_resource.server_src_dir}
      ./configure --prefix=/usr \
          --mandir=/usr/share/man \
          --bindir=/usr/sbin \
          --sbindir=#{node['nagios']['cgi-bin']} \
          --datadir=#{node['nagios']['docroot']} \
          --sysconfdir=#{node['nagios']['conf_dir']} \
          --infodir=/usr/share/info \
          --libexecdir=#{node['nagios']['plugin_dir']} \
          --localstatedir=#{node['nagios']['state_dir']} \
          --enable-event-broker \
          --with-nagios-user=#{new_resource.nagios_user} \
          --with-nagios-group=#{new_resource.nagios_group} \
          --with-command-user=#{new_resource.nagios_user} \
          --with-command-group=#{new_resource.nagios_group} \
          --with-init-dir=/etc/init.d \
          --with-lockfile=#{node['nagios']['run_dir']}/#{node['nagios']['server']['vname']}.pid \
          --with-mail=/usr/bin/mail \
          --with-perlcache \
          --with-htmurl=/ \
          --with-cgiurl=#{node['nagios']['cgi-path']}
      make all
      make install
      make install-init
      make install-config
      make install-commandmode
      #{node['nagios']['source']['add_build_commands'].join("\n")}
    EOH
    action :nothing
    subscribes :run, 'execute[extract-nagios]', :immediately
  end

  directory node['nagios']['config_dir'] do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  directory node['nagios']['conf']['check_result_path'] do
    owner new_resource.nagios_user
    group new_resource.nagios_group
    mode '0755'
    recursive true
  end

  %w( cache_dir log_dir run_dir ).each do |dir|
    directory node['nagios'][dir] do
      recursive true
      owner new_resource.nagios_user
      group new_resource.nagios_group
      mode '0755'
    end
  end

  directory ::File.join(node['nagios']['log_dir'], 'archives') do
    owner new_resource.nagios_user
    group new_resource.nagios_group
    mode '0755'
  end

  directory "/usr/lib/#{node['nagios']['server']['vname']}" do
    owner new_resource.nagios_user
    group new_resource.nagios_group
    mode '0755'
  end
end
