Vagrant.configure(2) do |config|
  config.vm.network "private_network", type: "dhcp"
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get install -y ntp"
  config.vm.provision "shell", inline: "apt-get install -y ubuntu-cloud-keyring"
  config.vm.provision "shell", inline: "echo \"deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main\" > /etc/apt/sources.list.d/cloudarchive-kilo.list"
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get dist-upgrade -y"
  config.vm.provision "shell", inline: "DEBIAN_FRONTEND=noninteractive apt-get install -q -y mariadb-server python-mysqldb" 
  config.vm.provision "shell", inline: "sudo cp /vagrant/mysqld_openstack.cnf /etc/mysql/conf.d/mysqld_openstack.cnf"
  config.vm.provision "shell", inline: "service mysql restart"
  config.vm.provision "shell", inline: "apt-get install -y rabbitmq-server"
  config.vm.provision "shell", inline: "rabbitmqctl add_user openstack secret"
  config.vm.provision "shell", inline: "rabbitmqctl set_permissions openstack \".*\" \".*\" \".*\""
  config.vm.provision "shell", inline: "echo \"manual\" > /etc/init/keystone.override"
  config.vm.provision "shell", inline: "apt-get install -y keystone python-openstackclient apache2 libapache2-mod-wsgi memcached python-memcache"
  config.vm.provision "shell", inline: "mysql -u root < /vagrant/keystone_db_init.sql"
  config.vm.provision "shell", inline: "cp /vagrant/keystone.conf /etc/keystone/keystone.conf"
  config.vm.provision "shell", inline: "su -s /bin/sh -c \"keystone-manage db_sync\" keystone"

  config.vm.define "ctrl" do |ctrl|
   ctrl.vm.box = "ubuntu/trusty64"
   ctrl.vm.hostname = "controller"
  end

  config.vm.define "net" do |net|
   net.vm.box = "ubuntu/trusty64"
  end

  config.vm.define "cpu" do |cpu|
   cpu.vm.box = "ubuntu/trusty64"
  end
end
