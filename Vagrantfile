#
#
# OpenStack Kilo on Ubuntu 14.04 LTS
#
# Justin Unger, October 2015 <justinunger@gmail.com>
#

Vagrant.configure(2) do |config|

config.vm.provider "virtualbox" do |v|
  v.memory = 3072
  v.cpus = 1
end

  config.hostmanager.enabled = true

  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get install -y ntp"
  config.vm.provision "shell", inline: "apt-get install -y ubuntu-cloud-keyring"
  config.vm.provision "shell", inline: "echo \"deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main\" > /etc/apt/sources.list.d/cloudarchive-kilo.list"
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get dist-upgrade -y"

  config.vm.define "ctrl" do |ctrl|
   ctrl.vm.box = "ubuntu/trusty64"
   ctrl.vm.hostname = "controller"
   ctrl.vm.network "private_network", ip: "172.16.172.10"
   ctrl.vm.network :forwarded_port, guest:6080, host:6080

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

	#
	# verify keystone functionality
	#
	sed -i 's/\ admin_token_auth//' /etc/keystone/keystone-paste.ini 
	unset OS_TOKEN OS_URL
	openstack --os-auth-url http://controller:35357 --os-project-name admin --os-username admin --os-auth-type password --os-password secret token issue
	openstack --os-auth-url http://controller:35357 --os-project-domain-id default --os-user-domain-id default --os-project-name admin --os-username admin --os-auth-type password --os-password secret token issue
	openstack --os-auth-url http://controller:35357 --os-project-name admin --os-username admin --os-auth-type password --os-password secret project list
	openstack --os-auth-url http://controller:35357 --os-project-name admin --os-username admin --os-auth-type password --os-password secret user list
	openstack --os-auth-url http://controller:35357 --os-project-name admin --os-username admin --os-auth-type password --os-password secret role list
	openstack --os-auth-url http://controller:5000 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-auth-type password --os-password secret token issue
	# this command is expected to fail
	openstack --os-auth-url http://controller:5000 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-auth-type password --os-password secret user list || true
	
	#
	# 
	#
	cp /vagrant/admin-openrc.sh .
	cp /vagrant/demo-openrc.sh .

	#
	# Install and configure image server (glance)
	#
	mysql -u root < /vagrant/glance_db_init.sql
	source admin-openrc.sh
	openstack user create --password secret glance
	openstack role add --project service --user glance admin
	openstack service create --name glance --description "OpenStack Image service" image
	openstack endpoint create --publicurl http://controller:9292 --internalurl http://controller:9292 --adminurl http://controller:9292 --region regionOne image
	apt-get install -y glance python-glanceclient
	cp /vagrant/glance-api.conf /etc/glance/glance-api.conf
	cp /vagrant/glance-registry.conf /etc/glance/glance-registry.conf
	su -s /bin/sh -c "glance-manage db_sync" glance
	service glance-registry restart
	service glance-api restart
	rm -f /var/lib/glance/glance.sqlite

	#
	# lets take glance for a spin. download cirros from the internet and put it in glance
	#
	source admin-openrc.sh
	mkdir /tmp/images
	wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
	glance image-create --name "cirros-0.3.4-x86_64" --file /tmp/images/cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress
	glance image-list

	#
	# install and configure nova (compute service)
	#
	mysql -u root < /vagrant/nova_db_init.sql
	openstack user create --password secret nova
	openstack role add --project service --user nova admin
	openstack service create --name nova --description "OpenStack Compute" compute
	openstack endpoint create --publicurl http://controller:8774/v2/%\\(tenant_id\\)s --internalurl http://controller:8774/v2/%\\(tenant_id\\)s --adminurl http://controller:8774/v2/%\\(tenant_id\\)s --region regionOne compute
	apt-get install -y nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient
	cp /vagrant/ctrl-nova.conf /etc/nova/nova.conf
	su -s /bin/sh -c "nova-manage db sync" nova	
	service nova-api restart
	service nova-cert restart
	service nova-consoleauth restart
	service nova-scheduler restart
	service nova-conductor restart
	service nova-novncproxy restart
	rm -rf /var/lib/nova/nova.sqlite

	#
	# install and configure neutron (network service)
	#
	mysql -u root < /vagrant/neutron_db_init.sql
	openstack user create --password secret neutron
	openstack role add --project service --user neutron admin
	openstack service create --name neutron --description "OpenStack Networking" network
	openstack endpoint create --publicurl http://controller:9696 --internalurl http://controller:9696 --adminurl http://controller:9696 --region regionOne network
	apt-get install -y neutron-server neutron-plugin-ml2 python-neutronclient
	cp /vagrant/neutron.conf /etc/neutron/neutron.conf
	cp /vagrant/ctrl-ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
	service nova-api restart
	service neutron-server restart
	sleep 5 && neutron ext-list
   SHELL
   
  end

  config.vm.define "net" do |net|
   net.vm.box = "ubuntu/trusty64"
   net.vm.hostname = "net"
   net.vm.network "private_network", ip: "172.16.172.12"
   net.vm.network "private_network", ip: "172.16.16.12"
   net.vm.network "public_network", auto_config: false
   net.vm.provision "shell", inline: <<-SHELL
     cp /vagrant/net-eth3.cfg /etc/network/interfaces.d/eth3.cfg
     cp /vagrant/net-sysctl.conf /etc/sysctl.conf
     sysctl -p
     apt-get install -y neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent
     cp /vagrant/net-neutron.conf /etc/neutron/neutron.conf
     cp /vagrant/net-ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
     cp /vagrant/l3_agent.ini /etc/neutron/l3_agent.ini
     cp /vagrant/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
     cp /vagrant/dnsmasq-neutron.conf /etc/neutron/dnsmasq-neutron.conf
     cp /vagrant/metadata_agent.ini /etc/neutron/metadata_agent.ini
     #pkill dnsmasq
     service openvswitch-switch restart
     ovs-vsctl add-br br-ex
     ovs-vsctl add-port br-ex eth3
     # the stock neutron_sudoers didn't seem to work here, so temporarily allow neutron user to do everything
     # this may be a security risk, but this environment is intended for development only
     cp /vagrant/neutron_sudoers /etc/sudoers.d/neutron_sudoers
     service neutron-plugin-openvswitch-agent restart
     service neutron-l3-agent restart
     service neutron-dhcp-agent restart
     service neutron-metadata-agent restart
     # to test run the next command on ctrl VM
     # neutron agent-list 
   SHELL
  end

  config.vm.define "cpu" do |cpu|
   cpu.vm.box = "ubuntu/trusty64"
   cpu.vm.hostname = "cpu"
   cpu.vm.network "private_network", ip: "172.16.172.11"
   cpu.vm.network "private_network", ip: "172.16.16.11"
   cpu.vm.provision "shell", inline: <<-SHELL
      apt-get install -y nova-compute sysfsutils
      cp /vagrant/cpu-nova.conf /etc/nova/nova.conf
      cp /vagrant/nova-compute.conf /etc/nova/nova-compute.conf
      service nova-compute restart
      rm -f /var/liob/nova/nova.sqlite
      cp /vagrant/cpu-sysctl.conf /etc/sysctl.conf
      apt-get install -y neutron-plugin-ml2 neutron-plugin-openvswitch-agent
      # looks like we can use the same neutron.conf from the net node on the cpu node
      cp /vagrant/net-neutron.conf /etc/neutron/neutron.conf
      cp /vagrant/cpu-ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
      # the stock neutron_sudoers didn't seem to work here, so temporarily allow neutron user to do everything
      # this may be a security risk, but this environment is intended for development only
      cp /vagrant/neutron_sudoers /etc/sudoers.d/neutron_sudoers
      service openvswitch-switch restart
      service nova-compute restart
      service neutron-plugin-openvswitch-agent restart
   SHELL
  end
end
