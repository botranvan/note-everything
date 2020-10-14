openstack address scope create --share --ip-version 4 bgp

openstack subnet pool create --address-scope bgp --pool-prefix 192.168.56.0/24 --pool-prefix 192.168.57.0/24 --pool-prefix 192.168.58.0/24 EXT_DIRECTNET
openstack subnet pool create --address-scope bgp --pool-prefix 192.0.2.0/20 --pool-prefix 192.0.2.128/20 --pool-prefix 192.0.8.0/21 --pool-prefix 192.0.9.0/22 --pool-prefix 192.89.0.0/19 dev-lb-mgmt-net


openstack network create EXT_DIRECTNET_6 --share --external --provider-physical-network provider --provider-network-type vlan --provider-segment 56
openstack network create EXT_DIRECTNET_7 --share --external --provider-physical-network provider --provider-network-type vlan --provider-segment 57
openstack network create EXT_DIRECTNET_8 --share --external --provider-physical-network provider --provider-network-type vlan --provider-segment 58

openstack subnet create --subnet-pool EXT_DIRECTNET --subnet-range 192.168.56.0/24 --gateway 192.168.56.1 --network EXT_DIRECTNET_6 --allocation-pool start=192.168.56.11,end=192.168.56.254 EXT_DIRECTNET_6
openstack subnet create --subnet-pool EXT_DIRECTNET --subnet-range 192.168.57.0/24 --gateway 192.168.57.1 --network EXT_DIRECTNET_7 --allocation-pool start=192.168.57.11,end=192.168.57.254 EXT_DIRECTNET_7
openstack subnet create --subnet-pool EXT_DIRECTNET --subnet-range 192.168.58.0/24 --gateway 192.168.58.1 --network EXT_DIRECTNET_8 --allocation-pool start=192.168.58.11,end=192.168.58.254 EXT_DIRECTNET_8


openstack network create dev-lb-mgmt-net
openstack subnet create --network dev-lb-mgmt-net --subnet-pool dev-lb-mgmt-net --prefix-length 20 dev-lb-mgmt-net

# openstack network create dev-frontend-net
# openstack subnet create --network dev-frontend-net --subnet-pool dev-lb-mgmt-net --prefix-length 21 dev-frontend-net




openstack bgp speaker create --local-as 62000 bgpspeaker
openstack bgp speaker add network bgpspeaker EXT_DIRECTNET_8

# add router + external + add interface for dev-lb-mgmt-net

# openstack bgp peer create --remote-as 62000 --peer-ip 192.0.0.1 bgppeer

# openstack bgp speaker add peer bgpspeaker bgppeer

# Make port
openstack port create --network dev-lb-mgmt-net --security-group lb-health-mgr-sec-grp --device-owner Octavia:health-mgr --host openstack2 dev-octavia-manage-openstack2

ovs-vsctl del-port dev-o-hm0
ovs-vsctl -- --may-exist add-port br-int dev-o-hm0 -- set Interface dev-o-hm0 type=internal -- set Interface dev-o-hm0 external-ids:iface-status=active -- set Interface dev-o-hm0 external-ids:attached-mac=fa:16:3e:1e:e9:e7 -- set Interface dev-o-hm0 external-ids:skip_cleanup=true -- set Interface dev-o-hm0 external-ids:iface-id=35b3ca4a-b02a-4b5e-a447-5675df178179
ip link set dev dev-o-hm0 address fa:16:3e:1e:e9:e7
dhclient -r dev-o-hm0
dhclient -v dev-o-hm0





-------------------------------------------
# Clear
openstack network delete EXT_DIRECTNET_5 EXT_DIRECTNET_6 EXT_DIRECTNET_7 EXT_DIRECTNET_8
openstack subnet pool delete EXT_DIRECTNET

openstack port delete dev-octavia-manage-openstack2 dev-octavia-manage-openstack
openstack network delete dev-lb-mgmt-net
openstack subnet pool delete dev-lb-mgmt-net

openstack bgp speaker delete bgpspeaker
openstack address scope delete bgp
