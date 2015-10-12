Vagrant.configure(2) do |config|

config.vm.provider "virtualbox" do |v|
  v.memory = 1024
  v.cpus = 4
end

  config.vm.network "private_network", type: "dhcp"
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get install -y ntp"
  config.vm.provision "shell", inline: "apt-get install -y ubuntu-cloud-keyring"
  config.vm.provision "shell", inline: "echo \"deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main\" > /etc/apt/sources.list.d/cloudarchive-kilo.list"
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get dist-upgrade -y"

  config.vm.define "ctrl" do |ctrl|
   ctrl.vm.box = "ubuntu/trusty64"
   ctrl.vm.hostname = "controller"

   ctrl.vm.provision "shell", inline: <<-SHELL
	#
	# install and configure mariadb (mysql) server for identity service (keystone)
	#
	DEBIAN_FRONTEND=noninteractive apt-get install -q -y mariadb-server python-mysqldb
	sudo cp /vagrant/mysqld_openstack.cnf /etc/mysql/conf.d/mysqld_openstack.cnf

	#
	# install and configure rabbitmq
	#
	service mysql restart
	apt-get install -y rabbitmq-server
	rabbitmqctl add_user openstack secret
	rabbitmqctl set_permissions openstack ".*" ".*" ".*"

	#
   	# setup identity service (keystone)
	#
        echo "manual" > /etc/init/keystone.override
	apt-get install -y keystone python-openstackclient apache2 libapache2-mod-wsgi memcached python-memcache
	mysql -u root < /vagrant/keystone_db_init.sql
	cp /vagrant/keystone.conf /etc/keystone/keystone.conf
	su -s /bin/sh -c "keystone-manage db_sync" keystone

	#
  	# set up apache for keystone
	#
	cp /vagrant/keystone-apache2.conf /etc/apache2/apache2.conf
	cp /vagrant/wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
	ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
	mkdir -p /var/www/cgi-bin/keystone
	curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo > /var/www/cgi-bin/keystone/main 
	cp /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin
	chown -R keystone:keystone /var/www/cgi-bin/keystone
	chmod 755 /var/www/cgi-bin/keystone/*
	service apache2 restart

	#
	# create service entry and API endpoint
	#
	export OS_TOKEN=1d71965befaa52845263
	export OS_URL=http://controller:35357/v2.0
	openstack service create --name keystone --description "OpenStack Identity" identity
	openstack endpoint create --publicurl http://controller:5000/v2.0 --internalurl http://controller:5000/v2.0 --adminurl http://controller:35357/v2.0 --region regionOne identity

	#
	# create tenants, users, and roles
	#
	openstack project create --description "Admin Project" admin
	openstack user create --password "secret" admin
	openstack role create admin
	openstack role add --project admin --user admin admin
	openstack project create --description "Service Project" service
	openstack project create --description "Demo Project" demo
	openstack user create --password "secret" demo
	openstack role create user
	openstack role add --project demo --user demo user
   SHELL
   
  end

  config.vm.define "net" do |net|
   net.vm.box = "ubuntu/trusty64"
  end

  config.vm.define "cpu" do |cpu|
   cpu.vm.box = "ubuntu/trusty64"
  end
end
