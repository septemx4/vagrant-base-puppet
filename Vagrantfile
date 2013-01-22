# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  # For building the (golden) base box with puppet support.
  # Repackage with "vagrant package --vagrantfile Vagrantfile.pkg"
  
  config.vm.box = "minimal"
  config.vm.box_url = "http://dl.dropbox.com/u/9806160/vagrant/vagrant-centos63-minimal.box"

  config.vm.customize ["modifyvm", :id, "--memory", 512]

  # Provisioning of the base box through a shell script
  config.vm.provision :shell, :path => "provisioning/bootstrap.sh" 

  # Provisioning of the base box through a puppet
  config.vm.provision :puppet do |puppet|
  	puppet.manifests_path = "provisioning/manifests"
  	puppet.manifest_file  = "base.pp"
  end

end
