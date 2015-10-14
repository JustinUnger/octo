OpenStack Kilo Ubuntu 14.04 Vagrant environment: based off the openstack kilo install instructions found at

http://docs.openstack.org/kilo/install-guide/install/apt/content/

This Vagrantfile will launch 3 VMs: ctrl, net and cpu. ctrl is the openstack "controller","net" is the network node and cpu is the compute node. 

To bring up the environment, you must first install vagrant and add the vagrant-hostmanager plugin. After installation, you can simply bring up the 3 VMs.

$ vagrant plugin install vagrant-hostmanager
$ vagrant up

After a while, you should have the 3 openstack nodes running: 

$ vagrant status
Current machine states:

ctrl                      running (virtualbox)
net                       running (virtualbox)
cpu                       running (virtualbox)

It would probably be a good time to do a quick sanity check to see if things are working. Connect to the control node and run a few openstack commands:

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
vagrant@controller:~$ neutron agent-list
+--------------------------------------+----------------+------+-------+----------------+------------------------+
| id                                   | agent_type     | host | alive | admin_state_up | binary                 |
+--------------------------------------+----------------+------+-------+----------------+------------------------+
| 21b9a747-3059-4329-a25d-1958c0e64357 | L3 agent       | net  | :-)   | True           | neutron-l3-agent       |
| 5369bb72-debf-4fe4-bf68-1cc7695a7c4b | Metadata agent | net  | :-)   | True           | neutron-metadata-agent |
| effd1700-7670-4cb8-bdd0-6debdcbce2e5 | DHCP agent     | net  | :-)   | True           | neutron-dhcp-agent     |
+--------------------------------------+----------------+------+-------+----------------+------------------------+
vagrant@controller:~$ glance image-list
+--------------------------------------+---------------------+
| ID                                   | Name                |
+--------------------------------------+---------------------+
| acc8ffd5-2b4a-4527-b0ea-04492c267eac | cirros-0.3.4-x86_64 |
+--------------------------------------+---------------------+


