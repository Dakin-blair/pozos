Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.hostname = "pozos-docker"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "pozos-docker-poc"
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.network "forwarded_port", guest: 80, host: 8888
  config.vm.network "forwarded_port", guest: 5000, host: 5000
  config.vm.network "forwarded_port", guest: 5001, host: 5001
  config.vm.network "forwarded_port", guest: 8081, host: 8081

  config.vm.provision "shell", path: "provision.sh"
end
