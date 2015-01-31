# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
box      = 'centos-65-x64-virtualbox-puppet'
hostname = 'zaqar-test'
domain   = 'example.com'
ram      = '512'

Vagrant::Config.run do |config|
  config.vm.customize [ 'modifyvm', :id, '--name', hostname, '--memory', ram ]
end

Vagrant.configure(2) do |config|
  config.vm.box = box
  config.vm.hostname = hostname + '.' + domain
  config.librarian_puppet.puppetfile_dir = "puppet/librarian-puppet"
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "site.pp"
    puppet.module_path = ["puppet/modules", "puppet/librarian-puppet/modules"]
    puppet.options = "--verbose"
  end
end
