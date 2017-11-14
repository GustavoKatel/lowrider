['vagrant-reload'].each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise "Vagrant plugin #{plugin} is not installed!"
  end
end

Vagrant.configure('2') do |config|

  config.vm.synced_folder "/home/gustavokatel/go/src/lowrider", "/lowrider"
  # config.vm.synced_folder "/media/Arquivos/g5/ufpb/TCC/lowrider_nf", "/lowrider_nf"

  config.vm.define "server", primary: true do |server|
    server.vm.box = "ubuntu/trusty64" # Ubuntu 14.04
    server.vm.network "private_network", ip: "192.168.50.4"

    config.vm.synced_folder "/tmp/vagrant_shared_server", "/shared", create: true

    # fix issues with slow dns https://www.virtualbox.org/ticket/13002
    server.vm.provider :libvirt do |libvirt|
      libvirt.connect_via_ssh = false
      libvirt.memory = 2048
      libvirt.cpus = 2
      libvirt.nic_model_type = "e1000"
    end

    server.vm.provision :shell, :privileged => true, :path => "setup-apt.sh"
    server.vm.provision :shell, :privileged => true, :path => "setup-kernel.sh"
    server.vm.provision :reload
    server.vm.provision :shell, :privileged => true, :path => "setup-bcc.sh"
    server.vm.provision :shell, :privileged => true, :path => "setup-xdp-script.sh"
  end

  config.vm.define "client" do |client|
    client.vm.box = "ubuntu/trusty64" # Ubuntu 14.04
    client.vm.network "private_network", ip: "192.168.50.5"

    config.vm.synced_folder "/tmp/vagrant_shared_client", "/shared", create: true

    client.vm.provider :libvirt do |libvirt|
      libvirt.connect_via_ssh = false
      libvirt.memory = 2048
      libvirt.cpus = 2
      libvirt.nic_model_type = "e1000"
    end

    client.vm.provision :shell, :privileged => true, :path => "setup-apt.sh"
    client.vm.provision :shell, :privileged => true, :path => "setup-kernel.sh"
    client.vm.provision :reload
    client.vm.provision :shell, :privileged => true, :path => "setup-bcc.sh"
    client.vm.provision :shell, :privileged => true, :path => "setup-xdp-script.sh"
  end

end