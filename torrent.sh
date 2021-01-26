#/bin/csh
#iocage jail creation
JAIL_NAME="torrent"
RELEASE="11.4"
IP_ADDR="172.16.0.5"
MASK_ADDR="27"
DEFAULT_ROUTER="172.16.0.1"
DHCP="0"
PACKAGES="wget ca_root_nss transmission-daemon transmission-web"
SYSRC="transmission_enable"
SERVICES="transmission"

USER="transmission"
UID="921"
GROUP="transmission"
GID="921"

echo -e "\nJail ${JAIL_NAME} in creation\n##############################\n"

iocage create -n "${JAIL_NAME}" \
  -r "${RELEASE}"-RELEASE \
  ip4_addr="vnet0|${IP_ADDR}/${MASK_ADDR}" \
  defaultrouter="${DEFAULT_ROUTER}" \
  vnet="on" \
  allow_raw_sockets="1" \
  boot="on" \
  nat="1" \
  nat_forwards="tcp(9091:9091),tcp(51413:51413),udp(51413:51413)" \
  mac_prefix="428d5c" \
  vnet0_mac="428d5cc03ad8 428d5cc03ad9" \
  vnet_default_interface="auto" \
  host_hostname="${JAIL_NAME}" \
  host_hostuuid="${JAIL_NAME}" \
  allow_mount_devfs="1" \
  allow_raw_sockets="1"
#  vnet="1" \

echo -e "\nRestarting jail ${JAIL_NAME}\n################################\n"

#restarting jail
iocage restart "${JAIL_NAME}"

echo -e "\nFolder and user creation, permission and mounting\n###############################################\n"
#iocage folder creation and mounting
#mkdir
iocage exec "${JAIL_NAME}" "mkdir -p /usr/local/etc/transmission/"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/torrents/"
echo -e "mkdir done"
#create user and group
iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP} -g ${GID}"
iocage exec "${JAIL_NAME}" "pw useradd -n ${USER} -u ${UID} -d /nonexistent -s /usr/sbin/nologin"
iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP} -m ${USER}"
echo -e "group and user creation done"
#chmod
iocage exec "${JAIL_NAME}" "chown ${USER}:${GROUP} /usr/local/etc/transmission/"
iocage exec "${JAIL_NAME}" "chown ${USER}:${GROUP} /mnt/torrents/"
echo -e "setting permissions done"
#mounting
iocage fstab -a "${JAIL_NAME}" /mnt/system_cache/Torrent_conf/root /root nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" /mnt/system_cache/Torrent_conf/transmission/home /usr/local/etc/transmission nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" /mnt/system_cache/Downloads/torrents /mnt/torrents/ nullfs rw 0 0

echo -e "mounting done"

#update jail and package install
echo -e "Jail update and packages install"

iocage exec "${JAIL_NAME}" "pkg-static install -y pkg"
iocage exec "${JAIL_NAME}" "pkg update"
iocage exec "${JAIL_NAME}" "pkg upgrade"
iocage exec "${JAIL_NAME}" "pkg install -y wget ${PACKAGES}"

echo -e "pkg update and packages installation done"

iocage exec "${JAIL_NAME}" "sysrc transmission_conf_dir=\"/usr/local/etc/transmission/\""
iocage exec "${JAIL_NAME}" "sysrc transmission_download_dir=\"/mnt/torrents/\""
for SYSRC_NAME in "${SYSRC}"; do
  iocage exec "${JAIL_NAME}" sysrc "${SYSRC_NAME}"=yes
done

for SERVICE_NAME in "${SERVICES}"; do
  iocage exec "${JAIL_NAME}" service "${SERVICE_NAME}" start
done

echo -e "sysrc and services start done\nscript done"

