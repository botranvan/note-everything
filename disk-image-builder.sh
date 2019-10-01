export CONTROLLER_IP=192.168.53.89
export ELEMENTS_PATH="/opt/stack/diskimage-builder/diskimage_builder/elements"
export ELEMENTS_PATH+=":/opt/stack/trove/integration/scripts/files/elements"
export TROVESTACK_SCRIPTS="/opt/stack/trove/integration/scripts"
export GUEST_USERNAME=ministry
export HOST_USERNAME=stack
export HOST_SCP_USERNAME=stack
export OS_NAME=ubuntu
export RELEASE=bionic
export DIB_RELEASE=bionic
export SERVICE_TYPE=mysql
export SSH_DIR="/opt/stack/.ssh"
# in /opt/stack run command:
# mkdir .ssh && chmod 700 .ssh
# ssh-genkey -b 2048 -t rsa
# cat id_rsa.pub >> authorized_keys
export DIB_APT_CONF_DIR=/etc/apt/apt.conf.d
export DIB_CLOUD_INIT_ETC_HOSTS=true
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
# export DATASTORE_PKG_LOCATION=mysql-community-server_5.7.24-1ubuntu16.04_amd64.deb

disk-image-create -a amd64 -o ${OS_NAME}-${RELEASE}-mysql vm ${OS_NAME} ${OS_NAME}-guest ${OS_NAME}-${RELEASE}-guest cloud-init-datasources ${OS_NAME}-${SERVICE_TYPE} ${OS_NAME}-${RELEASE}-mysql

# integration/scripts/files/elements/ubuntu-guest/pre-install.d/04-baseline-tools
# replace python-software-properties to software-properties-common
# file config log /etc/trove/trove-logging-guestagent.conf
# wget https://raw.githubusercontent.com/openstack/trove/master/etc/trove/trove-logging-guestagent.conf -O /etc/trove/trove-logging-guestagent.conf
# touch /var/log/trove-guestagent.log
# chmod 622 /var/log/trove-guestagent.log
# chmod 644 /etc/trove/conf.d/trove-guestagent.conf
# chmod 644 /etc/trove/conf.d/guest_info.conf
# service trove-guestagent restart
# file log for /var/log/trove-guestagent.log (config on trove-logging-guestagent.conf)
# mysql version 5.5
# create security group rule

# Update database store
openstack image create mysql-5.5 --disk-format qcow2 --container-format bare --public --file

trove-manage --config-file=/etc/trove/trove.conf datastore_update mysql ""

trove-manage --config-file=/etc/trove/trove.conf datastore_version_update mysql mysql-5.5 mysql GLANCE_ID "" 1

trove-manage db_load_datastore_config_parameters mysql mysql-5.5 /usr/lib/python2.7/dist-packages/trove/templates/mysql/validation-rules.json
