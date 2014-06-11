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
    nagios.vm.box = 'chef/ubuntu-10.04'
    nagios.vm.forward_port 80, 8080
    nagios.vm.host_name = 'nagios-1004'
  end

  config.vm.define :nagios_1204 do |nagios|
    nagios.vm.box = 'chef/ubuntu-12.04'
    nagios.vm.forward_port 80, 8081
    nagios.vm.host_name = 'nagios-1204'
  end

  config.vm.define :nagios_65 do |nagios|
    nagios.vm.box = 'chef/centos-6.5'
    nagios.vm.forward_port 80, 8082
    nagios.vm.host_name = 'nagios-65'
  end

  config.vm.define :nagios_510 do |nagios|
    nagios.vm.box = 'chef/centos-5.10'
    nagios.vm.forward_port 80, 8083
    nagios.vm.host_name = 'nagios-510'
  end

end
