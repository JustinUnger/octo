OpenStack Kilo Ubuntu 14.04 Vagrant environment: based off the openstack kilo install instructions found at

http://docs.openstack.org/kilo/install-guide/install/apt/content/

This Vagrantfile will launch 3 VMs: ctrl, net and cpu. ctrl is the openstack "controller","net" is the network node and cpu is the compute node. 

To bring up the environment, you must first install vagrant and add the vagrant-hostmanager plugin. After installation, you can simply bring up the 3 VMs.

Vagrant install instructions: https://docs.vagrantup.com/v2/installation/index.html

Once vagrant is installed, run: 

```
$ vagrant plugin install vagrant-hostmanager
$ vagrant up
```

During the VM bring up, you will be asked which network interface on your host machine you wish to attach the external NIC on the net VM: 
```
==> net: Available bridged network interfaces:
1) en0: Wi-Fi (AirPort)
2) p2p0
3) awdl0
==> net: When choosing an interface, it is usually the one that is
==> net: being used to connect to the internet.
    net: Which interface should the network bridge to? 1
```

After a while, you should have the 3 openstack nodes running: 

```
$ vagrant status
Current machine states:

ctrl                      running (virtualbox)
net                       running (virtualbox)
cpu                       running (virtualbox)
```

It would probably be a good time to do a quick sanity check to see if things are working. Connect to the control node and run a few openstack commands:

```
$ vagrant ssh ctrl
Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-65-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

  System information as of Wed Oct 14 03:08:41 UTC 2015

  System load:  0.57              Processes:           127
  Usage of /:   4.3% of 39.34GB   Users logged in:     0
  Memory usage: 57%               IP address for eth0: 10.0.2.15
  Swap usage:   0%                IP address for eth1: 172.16.172.10

  Graph this data and manage this system at:
    https://landscape.canonical.com/

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud


Last login: Wed Oct 14 03:08:41 2015 from 10.0.2.2
vagrant@controller:~$ source admin-openrc.sh 
vagrant@controller:~$ nova service-list
+----+------------------+------------+----------+---------+-------+----------------------------+-----------------+
| Id | Binary           | Host       | Zone     | Status  | State | Updated_at                 | Disabled Reason |
+----+------------------+------------+----------+---------+-------+----------------------------+-----------------+
| 1  | nova-scheduler   | controller | internal | enabled | up    | 2015-10-14T03:15:55.000000 | -               |
| 2  | nova-cert        | controller | internal | enabled | up    | 2015-10-14T03:16:00.000000 | -               |
| 3  | nova-consoleauth | controller | internal | enabled | up    | 2015-10-14T03:15:54.000000 | -               |
| 4  | nova-conductor   | controller | internal | enabled | up    | 2015-10-14T03:15:55.000000 | -               |
| 5  | nova-compute     | cpu        | nova     | enabled | up    | 2015-10-14T03:15:58.000000 | -               |
+----+------------------+------------+----------+---------+-------+----------------------------+-----------------+

vagrant@controller:~$ neutron ext-list
+-----------------------+-----------------------------------------------+
| alias                 | name                                          |
+-----------------------+-----------------------------------------------+
| security-group        | security-group                                |
| l3_agent_scheduler    | L3 Agent Scheduler                            |
| net-mtu               | Network MTU                                   |
| ext-gw-mode           | Neutron L3 Configurable external gateway mode |
| binding               | Port Binding                                  |
| provider              | Provider Network                              |
| agent                 | agent                                         |
| quotas                | Quota management support                      |
| subnet_allocation     | Subnet Allocation                             |
| dhcp_agent_scheduler  | DHCP Agent Scheduler                          |
| l3-ha                 | HA Router extension                           |
| multi-provider        | Multi Provider Network                        |
| external-net          | Neutron external network                      |
| router                | Neutron L3 Router                             |
| allowed-address-pairs | Allowed Address Pairs                         |
| extraroute            | Neutron Extra Route                           |
| extra_dhcp_opt        | Neutron Extra DHCP opts                       |
| dvr                   | Distributed Virtual Router                    |
+-----------------------+-----------------------------------------------+

vagrant@controller:~$ glance image-list
+--------------------------------------+---------------------+
| ID                                   | Name                |
+--------------------------------------+---------------------+
| acc8ffd5-2b4a-4527-b0ea-04492c267eac | cirros-0.3.4-x86_64 |
+--------------------------------------+---------------------+

vagrant@controller:~$ neutron agent-list
+--------------------------------------+--------------------+------+-------+----------------+---------------------------+
| id                                   | agent_type         | host | alive | admin_state_up | binary                    |
+--------------------------------------+--------------------+------+-------+----------------+---------------------------+
| 2f38dbee-ea74-4320-aaef-80fb55950cad | Open vSwitch agent | cpu  | :-)   | True           | neutron-openvswitch-agent |
| 505e1993-6b15-42f7-9864-2c3d3506cb42 | Open vSwitch agent | net  | :-)   | True           | neutron-openvswitch-agent |
| 7eed9b37-29f8-46ea-afa0-5f4b66de0db7 | L3 agent           | net  | :-)   | True           | neutron-l3-agent          |
| aeaece1e-3c80-46c2-9976-867798a0cae8 | Metadata agent     | net  | :-)   | True           | neutron-metadata-agent    |
| c8cd732e-3c6e-4839-a0f2-2fdb88da7c00 | DHCP agent         | net  | :-)   | True           | neutron-dhcp-agent        |
+--------------------------------------+--------------------+------+-------+----------------+---------------------------+

```

If things look good at this point, we can try to create the demo networks as described in http://docs.openstack.org/kilo/install-guide/install/apt/content/neutron_initial-external-network.html. There is a shell script you can run to do this quickly:

```
vagrant@controller:~$ bash -x /vagrant/create-demo-nets.sh 
+ source admin-openrc.sh
++ export OS_PROJECT_DOMAIN_ID=default
++ OS_PROJECT_DOMAIN_ID=default
++ export OS_USER_DOMAIN_ID=default
++ OS_USER_DOMAIN_ID=default
++ export OS_PROJECT_NAME=admin
++ OS_PROJECT_NAME=admin
++ export OS_TENANT_NAME=admin
++ OS_TENANT_NAME=admin
++ export OS_USERNAME=admin
++ OS_USERNAME=admin
++ export OS_PASSWORD=secret
++ OS_PASSWORD=secret
++ export OS_AUTH_URL=http://controller:35357/v3
++ OS_AUTH_URL=http://controller:35357/v3
++ export OS_IMAGE_API_VERSION=2
++ OS_IMAGE_API_VERSION=2
+ neutron net-create ext-net --router:external --provider:physical_network external --provider:network_type flat
Created a new network:
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| id                        | 6ac9956e-1992-4978-a341-66d9ad9f93b0 |
| mtu                       | 0                                    |
| name                      | ext-net                              |
| provider:network_type     | flat                                 |
| provider:physical_network | external                             |
| provider:segmentation_id  |                                      |
| router:external           | True                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tenant_id                 | 0cbfe90e149a43e081cd4c8ea6324727     |
+---------------------------+--------------------------------------+
+ neutron subnet-create ext-net 10.0.0.0/8 --name ext-subnet --allocation-pool start=10.0.0.100,end=10.0.0.150 --disable-dhcp --gateway 10.0.0.1
Created a new subnet:
+-------------------+----------------------------------------------+
| Field             | Value                                        |
+-------------------+----------------------------------------------+
| allocation_pools  | {"start": "10.0.0.100", "end": "10.0.0.150"} |
| cidr              | 10.0.0.0/8                                   |
| dns_nameservers   |                                              |
| enable_dhcp       | False                                        |
| gateway_ip        | 10.0.0.1                                     |
| host_routes       |                                              |
| id                | 98dd4e12-5d80-4b8a-b451-024d860028e3         |
| ip_version        | 4                                            |
| ipv6_address_mode |                                              |
| ipv6_ra_mode      |                                              |
| name              | ext-subnet                                   |
| network_id        | 6ac9956e-1992-4978-a341-66d9ad9f93b0         |
| subnetpool_id     |                                              |
| tenant_id         | 0cbfe90e149a43e081cd4c8ea6324727             |
+-------------------+----------------------------------------------+
+ source demo-openrc.sh
++ export OS_PROJECT_DOMAIN_ID=default
++ OS_PROJECT_DOMAIN_ID=default
++ export OS_USER_DOMAIN_ID=default
++ OS_USER_DOMAIN_ID=default
++ export OS_PROJECT_NAME=demo
++ OS_PROJECT_NAME=demo
++ export OS_TENANT_NAME=demo
++ OS_TENANT_NAME=demo
++ export OS_USERNAME=demo
++ OS_USERNAME=demo
++ export OS_PASSWORD=secret
++ OS_PASSWORD=secret
++ export OS_AUTH_URL=http://controller:5000/v3
++ OS_AUTH_URL=http://controller:5000/v3
++ export OS_IMAGE_API_VERSION=2
++ OS_IMAGE_API_VERSION=2
+ neutron net-create demo-net
Created a new network:
+-----------------+--------------------------------------+
| Field           | Value                                |
+-----------------+--------------------------------------+
| admin_state_up  | True                                 |
| id              | 366f44ec-a5a5-4588-a0ee-06f3b740009b |
| mtu             | 0                                    |
| name            | demo-net                             |
| router:external | False                                |
| shared          | False                                |
| status          | ACTIVE                               |
| subnets         |                                      |
| tenant_id       | 736313e8c4554fd998672135c2857204     |
+-----------------+--------------------------------------+
+ neutron subnet-create demo-net 192.168.1.0/24 --name demo-subnet --gateway 192.168.1.1
Created a new subnet:
+-------------------+--------------------------------------------------+
| Field             | Value                                            |
+-------------------+--------------------------------------------------+
| allocation_pools  | {"start": "192.168.1.2", "end": "192.168.1.254"} |
| cidr              | 192.168.1.0/24                                   |
| dns_nameservers   |                                                  |
| enable_dhcp       | True                                             |
| gateway_ip        | 192.168.1.1                                      |
| host_routes       |                                                  |
| id                | 93ed03cb-9b18-4769-a0e6-dcc27fc9cbd4             |
| ip_version        | 4                                                |
| ipv6_address_mode |                                                  |
| ipv6_ra_mode      |                                                  |
| name              | demo-subnet                                      |
| network_id        | 366f44ec-a5a5-4588-a0ee-06f3b740009b             |
| subnetpool_id     |                                                  |
| tenant_id         | 736313e8c4554fd998672135c2857204                 |
+-------------------+--------------------------------------------------+
+ neutron router-create demo-router
Created a new router:
+-----------------------+--------------------------------------+
| Field                 | Value                                |
+-----------------------+--------------------------------------+
| admin_state_up        | True                                 |
| external_gateway_info |                                      |
| id                    | 139939ac-85df-48b5-bfc3-c803a05e97f9 |
| name                  | demo-router                          |
| routes                |                                      |
| status                | ACTIVE                               |
| tenant_id             | 736313e8c4554fd998672135c2857204     |
+-----------------------+--------------------------------------+
+ neutron router-interface-add demo-router demo-subnet
Added interface e583fe68-b7e9-421b-b13a-a089e9d3094c to router demo-router.
+ neutron router-gateway-set demo-router ext-net
Set gateway for router demo-router
```

Now launch a demo VM:

```
vagrant@controller:~$ bash -x /vagrant/create-demo-vm.sh 
+ source demo-openrc.sh
++ export OS_PROJECT_DOMAIN_ID=default
++ OS_PROJECT_DOMAIN_ID=default
++ export OS_USER_DOMAIN_ID=default
++ OS_USER_DOMAIN_ID=default
++ export OS_PROJECT_NAME=demo
++ OS_PROJECT_NAME=demo
++ export OS_TENANT_NAME=demo
++ OS_TENANT_NAME=demo
++ export OS_USERNAME=demo
++ OS_USERNAME=demo
++ export OS_PASSWORD=secret
++ OS_PASSWORD=secret
++ export OS_AUTH_URL=http://controller:5000/v3
++ OS_AUTH_URL=http://controller:5000/v3
++ export OS_IMAGE_API_VERSION=2
++ OS_IMAGE_API_VERSION=2
+ nova keypair-add demo-key
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEArlivF/icY4gK+0yYMjsYU72Tp2wj35zbJTAvqp2s/5BqCic3
iWbNFgZb97AcifCNHYxnU98iZhs6X9Tc1lNJOHjyujJkQDgclOZYGnwrfszQC6Bf
y+JkE+OLrVfgmuhzjgf0+EkqpVXi9j/nKqVHFvBqFq0VOM+IlE8WuHbzWdWBTJ2n
C796uaAdT7RXSQJ39mXsJVtPN6FJAAIMcoXtgA4/kK2r5X74diizVyhsEqHrq5df
JSF/9IW5g60FVS6clRo0VtMxA6q8THk7GERNnNj3XEr7Fa9WD8CSeV8RMFx5gmKt
LwRGmoAT6oeC58YcCmF2iasK6R7f+RupLZT5ewIDAQABAoIBAH6H2FNSV9WYZzfo
Z9CUuNwVivKH9iUUhqsfpIhztJkpavwBaDntBMyGQvqosp2dmhymyFrDZwipnBzu
tHNLsKkuhiKB7eX5kyyxW6GlGkAFTrwRYVTr8evJSZa9X0GtkCe1OKF1IGEryvMi
f5egqc5JHwVkCjHX1GymVXv8wDIiIdwmAHU5ixYetWIt8Qi5yB3OhG1PzNnDtVDp
iCgMz9uZrWhSyuiTWKIPmJoziCE0YibOw2R1jqdBQhaOM0+mzAIc8Yp8xE228s4J
pd83VMg8Pasvwjg5Y2bYruL+K0ML02kFoLIVQE3zvOHsjYioF4PxTUri7X1SMGs8
0fO3nskCgYEA2KGkyts/Fm7IZvpgV5vcj5r2WYBzJ89XOI4JmjVr/FZXscmeqhUY
b/mE9Jwv8H1Ti3iI64OFlNiAwGJx54oy+XkrG8u4Rfjup/yv52uIBfODBJdkacog
A6+g8w9w+asI+Lym5GG/0QLbOROBo74UMNZFKDLSl+6W2zFPmmkOuG8CgYEAzgfQ
EGsdepqcJKqZRKs+ZIpmD5y1VUMHn8+lPYge2IlatEhlIktisGUK0CzznYaRChpC
r6jF8WyHZANiYvkMvnkwRb3tyzPsoW5h8CU1CbqxkoO5QcKvDXr2+20yYw+LSHf2
xrsu3QNI+VEIYgA8pGNTTSuWJGJq4U7+o804HbUCgYBDdwPVUTZyjAnJWExMvHOS
HZZ/BSvXyBDHwiRnbB+3NESXT80j9vHnXXP0ofekE8PC+cTaY9lkI5DlWUNT8owx
eXTdcTJwSDg7BMzba3evMsko0uUotRQHUdj0GWj7uDJRFJ99HJwaQaN4QQTss7Oi
Cfj7reg7/Mfqd47s7a7x7QKBgQCcJVWuK9BCrEysiVLxtSrrPezN5kGT5eIwX0nn
kXN3PtosijWDwUiBUYLZdUgI2gSweGiUAsBKEaumw93cDs52yRgpsyE2gRrU2fiF
7Vz+C60q0oQj762F9OycbwziANTZznmL8i85N5UlxyEoTO+o0tI+SUtYNfK04Y6h
jBX8hQKBgQCd3cHu8MBLD+2IAJaPPsaWwjk7E0EGWbagwINIXp/I3qTozqx8kXDF
254rYGrZJd9hFcNJ6pqaYJSxbhWpaxLkW5sGOd74iZAVx74FsDaCcUxIlEqjOI/C
JAMVNV1vX7GjufRbhS7o+dksM1bdoV9cTNti2lyhU+Nqj4NyC0RtgA==
-----END RSA PRIVATE KEY-----

+ nova keypair-list
+----------+-------------------------------------------------+
| Name     | Fingerprint                                     |
+----------+-------------------------------------------------+
| demo-key | 64:5c:01:fc:fa:8d:27:ec:58:d5:c7:ff:f1:38:fd:a3 |
+----------+-------------------------------------------------+
+ nova flavor-list
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
| ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
| 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
| 2  | m1.small  | 2048      | 20   | 0         |      | 1     | 1.0         | True      |
| 3  | m1.medium | 4096      | 40   | 0         |      | 2     | 1.0         | True      |
| 4  | m1.large  | 8192      | 80   | 0         |      | 4     | 1.0         | True      |
| 5  | m1.xlarge | 16384     | 160  | 0         |      | 8     | 1.0         | True      |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
+ nova image-list
+--------------------------------------+---------------------+--------+--------+
| ID                                   | Name                | Status | Server |
+--------------------------------------+---------------------+--------+--------+
| 1c84c991-223c-4e49-a5ba-fa154a7765d7 | cirros-0.3.4-x86_64 | ACTIVE |        |
+--------------------------------------+---------------------+--------+--------+
+ neutron net-list
+--------------------------------------+----------+-----------------------------------------------------+
| id                                   | name     | subnets                                             |
+--------------------------------------+----------+-----------------------------------------------------+
| 366f44ec-a5a5-4588-a0ee-06f3b740009b | demo-net | 93ed03cb-9b18-4769-a0e6-dcc27fc9cbd4 192.168.1.0/24 |
| 6ac9956e-1992-4978-a341-66d9ad9f93b0 | ext-net  | 98dd4e12-5d80-4b8a-b451-024d860028e3                |
+--------------------------------------+----------+-----------------------------------------------------+
++ neutron net-show demo-net -f value -c id
+ DEMO_NET_ID=366f44ec-a5a5-4588-a0ee-06f3b740009b
+ nova secgroup-list
+--------------------------------------+---------+------------------------+
| Id                                   | Name    | Description            |
+--------------------------------------+---------+------------------------+
| ef4c494e-1afa-4ba2-a638-92aaf8388928 | default | Default security group |
+--------------------------------------+---------+------------------------+
+ nova boot --flavor m1.tiny --image cirros-0.3.4-x86_64 --nic net-id=366f44ec-a5a5-4588-a0ee-06f3b740009b --security-group default --key-name demo-key demo-instance1
+--------------------------------------+------------------------------------------------------------+
| Property                             | Value                                                      |
+--------------------------------------+------------------------------------------------------------+
| OS-DCF:diskConfig                    | MANUAL                                                     |
| OS-EXT-AZ:availability_zone          | nova                                                       |
| OS-EXT-STS:power_state               | 0                                                          |
| OS-EXT-STS:task_state                | scheduling                                                 |
| OS-EXT-STS:vm_state                  | building                                                   |
| OS-SRV-USG:launched_at               | -                                                          |
| OS-SRV-USG:terminated_at             | -                                                          |
| accessIPv4                           |                                                            |
| accessIPv6                           |                                                            |
| adminPass                            | EzSRpAtoSE3R                                               |
| config_drive                         |                                                            |
| created                              | 2015-10-17T03:34:45Z                                       |
| flavor                               | m1.tiny (1)                                                |
| hostId                               |                                                            |
| id                                   | 2fa31a21-cb19-4d77-9462-b1edbc485552                       |
| image                                | cirros-0.3.4-x86_64 (1c84c991-223c-4e49-a5ba-fa154a7765d7) |
| key_name                             | demo-key                                                   |
| metadata                             | {}                                                         |
| name                                 | demo-instance1                                             |
| os-extended-volumes:volumes_attached | []                                                         |
| progress                             | 0                                                          |
| security_groups                      | default                                                    |
| status                               | BUILD                                                      |
| tenant_id                            | 736313e8c4554fd998672135c2857204                           |
| updated                              | 2015-10-17T03:34:45Z                                       |
| user_id                              | a7057c6e7c9445949598c5f919cff2c4                           |
+--------------------------------------+------------------------------------------------------------+
+ nova list
+--------------------------------------+----------------+--------+------------+-------------+----------+
| ID                                   | Name           | Status | Task State | Power State | Networks |
+--------------------------------------+----------------+--------+------------+-------------+----------+
| 2fa31a21-cb19-4d77-9462-b1edbc485552 | demo-instance1 | BUILD  | spawning   | NOSTATE     |          |
+--------------------------------------+----------------+--------+------------+-------------+----------+
+ nova get-vnc-console demo-instance1 novnc
ERROR (Conflict): Instance not yet ready (HTTP 409) (Request-ID: req-22f5f347-c7dd-4401-b0d7-b4b4282259d8)

vagrant@controller:~$ nova list
+--------------------------------------+----------------+--------+------------+-------------+----------------------+
| ID                                   | Name           | Status | Task State | Power State | Networks             |
+--------------------------------------+----------------+--------+------------+-------------+----------------------+
| 2fa31a21-cb19-4d77-9462-b1edbc485552 | demo-instance1 | ACTIVE | -          | Running     | demo-net=192.168.1.3 |
+--------------------------------------+----------------+--------+------------+-------------+----------------------+

vagrant@controller:~$ nova get-vnc-console demo-instance1 novnc
+-------+---------------------------------------------------------------------------------+
| Type  | Url                                                                             |
+-------+---------------------------------------------------------------------------------+
| novnc | http://controller:6080/vnc_auto.html?token=64fada73-a76e-4f7f-9181-fd067f2ded9a |
+-------+---------------------------------------------------------------------------------+
```

Now use the connect to the URL you got from the last command with a browser on the host machine. Replace "controller" with "localhost". The Vagrant file has forwarded port 6080 on your host machine to port 6080 on your controller VM. 

Viola, you should now have a VNC console into your VM. 


