Vagrant.require_plugin 'vagrant-chef-zero'
Vagrant.require_plugin 'vagrant-berkshelf'

 Vagrant.configure('2') do |config|
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true
  config.chef_zero.chef_repo_path = 'test/integration'
end

Vagrant::Config.run do |config|
  config.vm.provision :chef_client do |chef|
    chef.add_role('monitoring')
    chef.add_recipe('apt')
    chef.add_recipe('nagios::server')
  end

  config.vm.define :nagios_1004 do |nagios|
    nagios.vm.box = 'opscode-ubuntu-10.04'
    nagios.vm.forward_port 80, 8080
    nagios.vm.host_name = 'nagios-1004'
  end

  config.vm.define :nagios_1204 do |nagios|
    nagios.vm.box = 'opscode-ubuntu-12.04'
    nagios.vm.forward_port 80, 8081
    nagios.vm.host_name = 'nagios-1204'
  end

  config.vm.define :nagios_64 do |nagios|
    nagios.vm.box = 'opscode-centos-6.4'
    nagios.vm.forward_port 80, 8082
    nagios.vm.host_name = 'nagios-64'
  end

  config.vm.define :nagios_59 do |nagios|
    nagios.vm.box = 'opscode-centos-5.9'
    nagios.vm.forward_port 80, 8083
    nagios.vm.host_name = 'nagios-59'
  end

end
