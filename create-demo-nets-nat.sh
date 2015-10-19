source admin-openrc.sh
neutron net-create ext-net --router:external --provider:physical_network external --provider:network_type flat
neutron subnet-create ext-net 172.16.0.0/24 --name ext-subnet \
  --allocation-pool start=172.16.0.100,end=172.16.0.150 \
  --disable-dhcp --gateway 172.16.0.1

source demo-openrc.sh
neutron net-create demo-net
neutron subnet-create demo-net 192.168.1.0/24 --name demo-subnet --gateway 192.168.1.1
neutron router-create demo-router
neutron router-interface-add demo-router demo-subnet
neutron router-gateway-set demo-router ext-net
