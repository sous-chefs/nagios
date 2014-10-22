Vagrant.configure('2') do |config|
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true
  config.chef_zero.chef_repo_path = 'test/integration'

  unless Vagrant.has_plugin?('vagrant-berkshelf')
    fail 'Vagrant Berkshelf plugin not installed.  Run: vagrant plugin install vagrant-berkshelf'
  end

  unless Vagrant.has_plugin?('vagrant-omnibus')
    fail 'Vagrant Omnibus plugin not installed.  Run: vagrant plugin install vagrant-omnibus'
  end

  unless Vagrant.has_plugin?('vagrant-chef-zero')
    fail 'Vagrant Chef Zero plugin not installed.  Run: vagrant plugin install vagrant-chef-zero'
  end

end

Vagrant::Config.run do |config|
  config.vm.provision :chef_client do |chef|
    chef.add_role('monitoring')
    chef.add_recipe('apt')
    chef.add_recipe('nrpe::default')
    chef.add_recipe('nagios::default')
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

  config.vm.define :nagios_1404 do |nagios|
    nagios.vm.box = 'chef/ubuntu-14.04'
    nagios.vm.forward_port 80, 8082
    nagios.vm.host_name = 'nagios-1404'
  end

  config.vm.define :nagios_7 do |nagios|
    nagios.vm.box = 'chef/centos-7'
    nagios.vm.forward_port 80, 8083
    nagios.vm.host_name = 'nagios-7'
  end

  config.vm.define :nagios_65 do |nagios|
    nagios.vm.box = 'chef/centos-6.5'
    nagios.vm.forward_port 80, 8084
    nagios.vm.host_name = 'nagios-65'
  end

  config.vm.define :nagios_510 do |nagios|
    nagios.vm.box = 'chef/centos-5.10'
    nagios.vm.forward_port 80, 8085
    nagios.vm.host_name = 'nagios-510'
  end

end
