source demo-openrc.sh
nova keypair-add demo-key
nova keypair-list
nova flavor-list
nova image-list
neutron net-list
DEMO_NET_ID=`neutron net-show demo-net -f value -c id`
nova secgroup-list
nova boot --flavor m1.tiny --image cirros-0.3.4-x86_64 --nic net-id=$DEMO_NET_ID --security-group default --key-name demo-key demo-instance1
nova list
nova get-vnc-console demo-instance1 novnc

