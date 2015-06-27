# -*- mode: ruby -*-
# vi: set ft=ruby :

VM_CPUS = "1"
VM_MEMORY = "2048" # MB
VM_NIC_SPEED = "1000000"  # kbps
API_VER = "2"

Vagrant.configure(API_VER) do |config|
  numNodes = 2
  slaveStart = 1
  slaveEnd = numNodes
  (1..numNodes).each do |i|
    config.vm.define "node#{i}" do |node|
      #node.vm.box = "centos65"
      #node.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.1/centos65-x86_64-20131205.box"
      node.vm.box = "ubuntu1204"
      node.vm.box_url = "http://files.vagrantup.com/precise64.box"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "node#{i}"
        vb.customize [ "modifyvm", :id, 
                       "--memory", VM_MEMORY,
                       "--cpus", VM_CPUS,
                       "--nicspeed1", VM_NIC_SPEED,
                       "--nicspeed2", VM_NIC_SPEED,
                       "--ioapic", "on" ]
      end
      node.vm.network :private_network, ip: "10.211.55.10#{i}"
      node.vm.hostname = "node#{i}"

      # Provisions
      node.vm.provision "shell" do |s|
        s.path = "scripts/setup-os.sh"
        s.args = "-i #{i} -n #{numNodes}"
      end
      node.vm.provision "shell" do |s|
        s.path = "scripts/setup-libs.sh"
      end
      node.vm.provision "shell" do |s|
        s.path = "scripts/setup-hadoop.sh"
        s.args = "-s #{slaveStart} -e #{slaveEnd}"
      end
      node.vm.provision "shell" do |s|
        s.path = "scripts/setup-spark.sh"
        s.args = "-s #{slaveStart} -e #{slaveEnd}"
      end
    end
  end
end
