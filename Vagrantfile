# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.box = "centos72"

  #config.vm.provision "shell", privileged: false, inline: "echo 'export OPENWEBIF_URL="+ ENV['OPENWEBIF_URL'] + "' >> ~/.bash_profile"

  config.vm.provision "shell", path: "src/vagrant/install.sh", env: {
    "IN_OPENWEBIF_URL" => ENV['OPENWEBIF_URL'],
    "IN_AWS_LAMBDA_NAME" => ENV['AWS_LAMBDA_NAME'],
    "AWS_REGION" => ENV['AWS_REGION'],
    "AWS_KEY_ID" => ENV['AWS_KEY_ID'],
    "AWS_KEY_SECRET" => ENV['AWS_KEY_SECRET']
  }
end