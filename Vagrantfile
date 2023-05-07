NodeCount=0
MasterCount=1
IP_NW="10.0.0."
IP_START=10

Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update -y
        echo "$IP_NW$((IP_START))  master-node" >> /etc/hosts
        echo "$IP_NW$((IP_START+1))  worker-node01" >> /etc/hosts
        echo "$IP_NW$((IP_START+2))  worker-node02" >> /etc/hosts
    SHELL
    config.vm.box = "ubuntu/jammy64"
    config.vm.box_check_update = false #deshabilitamos el update automatico dle box

    (1..MasterCount).each do |i|
      config.vm.define "master0#{i}" do |master|
        master.vm.hostname = "master-node0#{i}"
        master.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
            master.vm.provider "virtualbox" do |vb|
            vb.memory = 4048
            vb.cpus = 2
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        end
      master.vm.provision "shell", path: "scripts/common.sh"
      #master.vm.provision "shell", path: "scripts/master.sh"
      end
    end

    (1..NodeCount).each do |i|
      config.vm.define "node0#{i}" do |node|
        node.vm.hostname = "worker-node0#{i}"
        node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
        node.vm.provider "virtualbox" do |vb|
            vb.memory = 2048
            vb.cpus = 1
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        end
        #node.vm.provision "shell", path: "scripts/common.sh"
        #node.vm.provision "shell", path: "scripts/node.sh"
      end
    end
  end