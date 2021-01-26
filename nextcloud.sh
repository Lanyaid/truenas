#/bin/csh
#iocage jail creation
JAIL_NAME="nextcloud"
RELEASE="11.4"
IP_ADDR="172.16.0.2"
MASK_ADDR="27"
DEFAULT_ROUTER="172.16.0.1"
DHCP="0"
PACKAGES="nano wget ca_root_nss nginx mysql80-server redis nextcloud-php80 php80 curl"
SYSRC="nginx mysql php_fpm redis"
SERVICES="nginx mysql-server php-fpm redis"

USER="www"
UID="80"
GROUP="www"
GID="80"
USER2="mysql"
UID2="88"
GROUP2="mysql"
GID2="88"


echo -e "\nJail ${JAIL_NAME} in creation\n##############################\n"

iocage create -n "${JAIL_NAME}" \
  -r "${RELEASE}"-RELEASE \
  ip4_addr="vnet0|${IP_ADDR}/${MASK_ADDR}" \
  defaultrouter="${DEFAULT_ROUTER}" \
  vnet="on" \
  allow_raw_sockets="1" \
  boot="on" \
  nat="1" \
  nat_forwards="tcp(80:443)" \
  mac_prefix="428d3c" \
  vnet0_mac="428d3cc03ad8 428d5cc03ad9" \
  vnet_default_interface="auto" \
  host_hostname="${JAIL_NAME}" \
  host_hostuuid="${JAIL_NAME}" \
  allow_mount_devfs="1" \
  allow_raw_sockets="1"
#  vnet="1" \

echo -e "\nRestarting jail ${JAIL_NAME}\n################################\n"

#restarting jail
iocage restart "${JAIL_NAME}"

echo -e "Folder and user creation, permission and mounting\n"
#iocage folder creation and mounting
#mkdir
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/www/nextcloud/apps"
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/www/nextcloud/apps-pkg"
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/www/nextcloud/config"
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/www/nextcloud/data"
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/www/nextcloud/themes"

iocage exec "${JAIL_NAME}" "mkdir -p /root"

iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/etc/nginx"

iocage exec "${JAIL_NAME}" "mkdir -p /var/db/mysql"



#create user and group
#iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP} -g ${GID}"
iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP2} -g ${GID2}"
#iocage exec "${JAIL_NAME}" "pw useradd -n ${USER} -u ${UID} -d /nonexistent -s /usr/sbin/nologin"
iocage exec "${JAIL_NAME}" "pw useradd -n ${USER2} -u ${UID2} -d /nonexistent -s /usr/sbin/nologin"
#iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP} -m ${USER}"
iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP2} -m ${USER2}"


#chown & chmod
iocage exec "${JAIL_NAME}" "chown -R ${USER}:wheel /usr/local/www"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/www"
iocage exec "${JAIL_NAME}" "chown -R ${USER2}:wheel /var/db/mysql"
iocage exec "${JAIL_NAME}" "chmod 770 /var/db/mysql"

 
#mounting

iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/apps" "/usr/local/www/nextcloud/apps" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/apps-pkg" "/usr/local/www/nextcloud/apps-pkg" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/config" "/usr/local/www/nextcloud/config" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_data" "/usr/local/www/nextcloud/data" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/themes" "/usr/local/www/nextcloud/themes" nullfs rw 0 0

iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/home_root" "/root" nullfs rw 0 0

iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/nginx" "/usr/local/etc/nginx" nullfs rw 0 0

iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_mysql" "/var/db/mysql" nullfs rw 0 0

														   
#update jail and package install
echo -e "\nJail update and packages install\n"            

iocage exec "${JAIL_NAME}" "pkg-static install -y pkg"
iocage exec "${JAIL_NAME}" "pkg update"
iocage exec "${JAIL_NAME}" "pkg upgrade"
iocage exec "${JAIL_NAME}" "pkg install -y wget ${PACKAGES}"


#for SYSRC_NAME in "${SYSRC}"; do
#  iocage exec "${JAIL_NAME}" sysrc "${SYSRC_NAME}_enable"=yes
#done
iocage exec "${JAIL_NAME}" "sysrc nginx_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc mysql_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc php_fpm_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc redis_enable=yes"


#for SERVICE_NAME in "${SERVICES}"; do
#  iocage exec "${JAIL_NAME}" service "${SERVICE_NAME}" start
#done
iocage exec "${JAIL_NAME}" "service mysql-server start"
iocage exec "${JAIL_NAME}" "service nginx start"
iocage exec "${JAIL_NAME}" "service php-fpm start"
iocage exec "${JAIL_NAME}" "service redis start"