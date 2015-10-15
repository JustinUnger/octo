OpenStack Kilo Ubuntu 14.04 Vagrant environment: based off the openstack kilo install instructions found at

http://docs.openstack.org/kilo/install-guide/install/apt/content/

This Vagrantfile will launch 3 VMs: ctrl, net and cpu. ctrl is the openstack "controller","net" is the network node and cpu is the compute node. 

To bring up the environment, you must first install vagrant and add the vagrant-hostmanager plugin. After installation, you can simply bring up the 3 VMs.
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



