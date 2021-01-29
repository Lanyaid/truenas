#/bin/csh
#iocage jail creation
JAIL_NAME="reverse-proxy"
RELEASE="11.4"
IP_ADDR="192.168.23.130"
MASK_ADDR="25"
DEFAULT_ROUTER="192.168.23.129"
DHCP="0"
PACKAGES="nano wget ca_root_nss nginx nano php80 python openssl py37-certbot-dns-ovh curl"
SYSRC="nginx"
SERVICES="nginx"

USER="www"
UID="80"
GROUP="www"
GID="80"


echo -e "\nJail ${JAIL_NAME} in creation\n##############################\n"

iocage create -n "${JAIL_NAME}" \
  -r "${RELEASE}"-RELEASE \
  ip4_addr="lagg0|${IP_ADDR}/${MASK_ADDR}" \
  defaultrouter="${DEFAULT_ROUTER}" \
  vnet="off" \
  allow_raw_sockets="1" \
  boot="on" \
  nat="0" \
  mac_prefix="428d2c" \
  vnet0_mac="428d2cc03ad8 428d5cc03ad9" \
  vnet_default_interface="auto" \
  host_hostname="${JAIL_NAME}" \
  host_hostuuid="${JAIL_NAME}" \
  allow_mount_devfs="1" \
  allow_raw_sockets="1"
#  vnet="0" \

echo -e "\nRestarting jail ${JAIL_NAME}\n################################\n"

#restarting jail
iocage restart "${JAIL_NAME}"

echo -e "Folder and user creation, permission and mounting\n"
#iocage folder creation and mounting
#mkdir

iocage exec "${JAIL_NAME}" "mkdir -p /root"
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/etc/nginx"
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/etc/letsencrypt/renewal"
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/www"


#create user and group
#iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP} -g ${GID}"
#iocage exec "${JAIL_NAME}" "pw useradd -n ${USER} -u ${UID} -d /nonexistent -s /usr/sbin/nologin"
#iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP} -m ${USER}"


#chown & chmod
iocage exec "${JAIL_NAME}" "chown -R root:wheel /usr/local/etc/nginx"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/etc/nginx"
iocage exec "${JAIL_NAME}" "chown -R root:wheel /usr/local/etc/letsencrypt/renewal"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/etc/letsencrypt/renewal"
iocage exec "${JAIL_NAME}" "chown -R ${USER}:wheel /usr/local/www"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/www"

 
#mounting

iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/Reverse-Proxy_conf/root" "/root" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/Reverse-Proxy_conf/nginx" "/usr/local/etc/nginx" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/Reverse-Proxy_conf/renewal" "/usr/local/etc/letsencrypt/renewal" nullfs rw 0 0

														   
#update jail and package install
echo -e "\nJail update and packages install\n"            

iocage exec "${JAIL_NAME}" "pkg-static install -y pkg"
iocage exec "${JAIL_NAME}" "pkg update"
iocage exec "${JAIL_NAME}" "pkg upgrade"
iocage exec "${JAIL_NAME}" "pkg install -y wget ${PACKAGES}"

iocage exec "${JAIL_NAME}" "curl https://ssl-config.mozilla.org/ffdhe2048.txt > /usr/local/etc/ssl/dhparam.pem"


#for SYSRC_NAME in "${SYSRC}"; do
#  iocage exec "${JAIL_NAME}" sysrc "${SYSRC_NAME}_enable"=yes
#done
iocage exec "${JAIL_NAME}" "sysrc nginx_enable=yes"


#for SERVICE_NAME in "${SERVICES}"; do
#  iocage exec "${JAIL_NAME}" service "${SERVICE_NAME}" start
#done
iocage exec "${JAIL_NAME}" "service nginx start"
