# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box_url = "https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box"
  config.vm.box = "centos71"

  #config.vm.provision "shell", privileged: false, inline: "echo 'export OPENWEBIF_URL="+ ENV['OPENWEBIF_URL'] + "' >> ~/.bash_profile"

  config.vm.provision "shell", path: "src/vagrant/install.sh", env: {
    "IN_AWS_LAMBDA_NAME" => ENV['AWS_LAMBDA_NAME'],
    "IN_AWS_REGION" => ENV['AWS_REGION'],
    "IN_AWS_KEY_ID" => ENV['AWS_KEY_ID'],
    "IN_AWS_KEY_SECRET" => ENV['AWS_KEY_SECRET'],
    "IN_AWS_DYNAMODB_KEY_ID" => ENV['AWS_DYNAMODB_KEY_ID'],
    "IN_AWS_DYNAMODB_KEY_SECRET" => ENV['AWS_DYNAMODB_KEY_SECRET'],
    "IN_AWS_DYNAMODB_REGION" => ENV['AWS_DYNAMODB_REGION'],
    "IN_OPENWEBIF_TABLENAME" => ENV['OPENWEBIF_TABLENAME']
  }
end
