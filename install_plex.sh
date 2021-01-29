#/bin/csh
#iocage jail creation
JAIL_NAME="plex"
RELEASE="11.4"
IP_ADDR="192.168.23.200"
MASK_ADDR="25"
DEFAULT_ROUTER="192.168.23.129"
DHCP="0"
PACKAGES="plexmediaserver ffmpeg"
SYSRC="plexmediaserver_enable"
SERVICES="plexmediaserver"

USER="plex"
UID="972"
GROUP="plex"
GID="972"
GROUP2="Multimedia"
GID2="1005"
GROUP3="Downloads"
GID3="892"

echo -e "\nJail ${JAIL_NAME} in creation\n##############################\n"

iocage create -n "${JAIL_NAME}" \
  -r "${RELEASE}"-RELEASE \
  ip4_addr="lagg0|${IP_ADDR}/${MASK_ADDR}" \
  defaultrouter="${DEFAULT_ROUTER}" \
  vnet="off" \
  allow_raw_sockets="1" \
  boot="on" \
  nat="0" \
  mac_prefix="428d4c" \
  vnet0_mac="428d4cc03ad8 428d5cc03ad9" \
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
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Animation"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Dessins-Animes"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Documentaires"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Films"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Formations"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Musique"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Photos"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Series"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/Multimedia/Spectacles"
iocage exec "${JAIL_NAME}" "mkdir -p /mnt/torrents"
iocage exec "${JAIL_NAME}" "mkdir -p '/usr/local/plexdata/Plex Media Server'"

#create user and group
iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP} -g ${GID}"
iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP2} -g ${GID2}"
iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP3} -g ${GID3}"
iocage exec "${JAIL_NAME}" "pw useradd -n ${USER} -u ${UID} -d /nonexistent -s /usr/sbin/nologin"
iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP} -m ${USER}"
iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP2} -m ${USER}"
iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP3} -m ${USER}"


#iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP2} -m root"
#iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP3} -m root"


#chown & chmod
iocage exec "${JAIL_NAME}" "chown -R ${USER}:${GROUP} '/usr/local/plexdata/Plex Media Server'"
iocage exec "${JAIL_NAME}" "chmod 770 '/usr/local/plexdata/Plex Media Server'"
iocage exec "${JAIL_NAME}" "chown -R root:${GROUP2} /mnt/Multimedia/"
iocage exec "${JAIL_NAME}" "chmod 770 /mnt/Multimedia/"
iocage exec "${JAIL_NAME}" "chown -R root:${GROUP3} /mnt/torrents/"
iocage exec "${JAIL_NAME}" "chmod 770 /mnt/torrents/"

 
#mounting
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Animation" "/mnt/Multimedia/Animation" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Dessins-Animes" "/mnt/Multimedia/Dessins-Animes" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Documentaires" "/mnt/Multimedia/Documentaires" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Films" "/mnt/Multimedia/Films" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Formations" "/mnt/Multimedia/Formations" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Musique" "/mnt/Multimedia/Musique" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Photos" "/mnt/Multimedia/Photos" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Series" "/mnt/Multimedia/Series" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/NAS-Volume/Multimedia/Spectacles" "/mnt/Multimedia/Spectacles" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/Downloads/torrents/completed" "/mnt/torrents" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/Plex_conf" "/usr/local/plexdata/Plex Media Server" nullfs rw 0 0

														   
echo -e "\nJail update and packages install\n"            
#update jail and package install

iocage exec "${JAIL_NAME}" "pkg-static install -y pkg"
iocage exec "${JAIL_NAME}" "pkg update"
iocage exec "${JAIL_NAME}" "pkg upgrade"
iocage exec "${JAIL_NAME}" "pkg install -y wget ${PACKAGES}"

#iocage exec "${JAIL_NAME}" "sysrc transmission_conf_dir=\"/usr/local/etc/transmission/\""

for SYSRC_NAME in "${SYSRC}"; do
  iocage exec "${JAIL_NAME}" sysrc "${SYSRC_NAME}"=yes
done

for SERVICE_NAME in "${SERVICES}"; do
  iocage exec "${JAIL_NAME}" service "${SERVICE_NAME}" start
done
