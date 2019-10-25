
openstack port create --network dev-lb-mgmt-net --security-group lb-health-mgr-sec-grp --device-owner Octavia:health-mgr --host openstack dev-octavia-manage-openstack2

ovs-vsctl -- --may-exist add-port br-int dev-o-hm0 -- set Interface dev-o-hm0 type=internal -- set Interface dev-o-hm0 external-ids:iface-status=active -- set Interface dev-o-hm0 external-ids:attached-mac=fa:16:3e:0c:07:34 -- set Interface dev-o-hm0 external-ids:skip_cleanup=true -- set Interface dev-o-hm0 external-ids:iface-id=cb5c1cf4-29b0-4a4c-ae35-999edbb1e7f1

ip link set dev dev-o-hm0 address fa:16:3e:0c:07:34
dhclient -v dev-o-hm0   