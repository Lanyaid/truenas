#/bin/csh
#iocage jail creation
JAIL_NAME="nextcloud"
RELEASE="11.4"
IP_ADDR="172.16.0.2"
MASK_ADDR="30"
DEFAULT_ROUTER="172.16.0.1"
HOST_PORT=8512
GUEST_PORT=80
DHCP="0"
PHP_PACKAGES="php74 php74-bz2 php74-ctype php74-curl php74-dom php74-exif php74-fileinfo php74-filter php74-gd php74-iconv php74-intl php74-json php74-ldap php74-mbstring php74-opcache php74-openssl php74-pdo php74-pdo_mysql php74-pecl-APCu php74-pecl-imagick php74-pecl-redis php74-posix php74-session php74-simplexml php74-xml php74-xmlreader php74-xmlwriter php74-xsl php74-zip php74-zlib php74-bcmath php74-gmp"
PACKAGES="nano wget ca_root_nss nginx mariadb104-server redis tree sudo git ${PHP_PACKAGES}"
SYSRC="nginx mysql php_fpm redis"
SERVICES=$( echo -e "nginx\nmysql-server\nphp-fpm\nredis" )
QUERY_CREATE_USER="CREATE DATABASE nextcloud;
CREATE USER 'nextcloud_dbadmin'@'localhost' IDENTIFIED BY 'your-password-here';
GRANT ALL ON nextcloud.* TO 'nextcloud_admin'@'localhost';
FLUSH PRIVILEGES;"
 
USER="www"
UID="80"
GROUP="www"
GID="80"
USER2="mysql"
UID2="88"
GROUP2="mysql"
GID2="88"

echo -e "\nJail ${JAIL_NAME} in creation\n##############################\n"

iocage create -n "${JAIL_NAME}" -r "${RELEASE}"-RELEASE \
  ip4_addr="vnet0|${IP_ADDR}/${MASK_ADDR}" \
  defaultrouter="${DEFAULT_ROUTER}" \
  vnet="1" \
  allow_raw_sockets="1" \
  boot="1" \
  nat="1" \
  nat_forwards="tcp(${GUEST_PORT}:${HOST_PORT})" \
  mac_prefix="428d5c" \
  vnet0_mac="428d5c6cb0ba 428d5c6cb0bb" \
  host_hostname="${JAIL_NAME}" \
  host_hostuuid="${JAIL_NAME}" \
  allow_mount_devfs="1" \
  allow_raw_sockets="1" \
  jail_zfs_dataset="iocage/jails/nextcloud/data"


echo -e "\nRestarting jail ${JAIL_NAME}\n################################\n"

#restarting jail
iocage restart "${JAIL_NAME}"

echo -e "\nFolder and user creation, permission and mounting\n"
#iocage folder creation and mounting
#mkdir outside jail
for PATH in $( cat ./config/outside_path.conf)
  do
  echo -e "New folder creation outside the jail : ${PATH}"
  if [[ ! -d "${PATH}" ]]
    then
    mkdir -p "${PATH}"
    else
    ls "{PATH}"
  fi
  if (( $? == "0" ))
    then
    echo -e "New folder creation outside the jail : ${PATH} [OK]"
    else
    echo -e "New folder creation outside the jail : ${PATH} [NOK]"
  fi
done 

#mkdir inside_jail
for PATH in $( cat ./config/inside_path.conf )
  do
  echo -e "New folder creation inside the jail : ${PATH}"
  iocage exec "${JAIL_NAME}" "mkdir -p ${PATH}"
  if (( $? == "0" ))
    then
    echo -e "New folder creation inside the jail : ${PATH} [OK]"
    else
    echo -e "New folder creation inside the jail : ${PATH} [NOK]"
  fi
done

#zfs set primarycache=metadata system_cache/NextCloud_data

#create user and group
#iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP} -g ${GID}"
iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP2} -g ${GID2}"
#iocage exec "${JAIL_NAME}" "pw useradd -n ${USER} -u ${UID} -d /nonexistent -s /usr/sbin/nologin"
iocage exec "${JAIL_NAME}" "pw useradd -n ${USER2} -u ${UID2} -d /nonexistent -s /usr/sbin/nologin"
#iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP} -m ${USER}"
iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP2} -m ${USER2}"

#chown & chmod
iocage exec "${JAIL_NAME}" "chown -R ${USER}:${GROUP} /usr/local/www"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/www"
iocage exec "${JAIL_NAME}" "chown -R ${USER2}:${GROUP2} /var/db/mysql"
iocage exec "${JAIL_NAME}" "chmod 770 /var/db/mysql"

#mounting

for MOUNT_PATH in $( cat ./config/mount_path.conf)
  do
  echo -e "New mount creation inside the jail : ${MOUNT_PATH}"
  iocage fstab -a "${JAIL_NAME}" "${MOUNT_PATH}"
done

#update jail and package install
echo -e "\nJail update and packages install\n"

iocage exec "${JAIL_NAME}" "pkg-static install -y pkg"
iocage exec "${JAIL_NAME}" "pkg update"
iocage exec "${JAIL_NAME}" "pkg upgrade"
iocage exec "${JAIL_NAME}" "pkg install -y wget ${PACKAGES}"

iocage exec "${JAIL_NAME}" "cd /tmp && wget https://download.nextcloud.com/server/releases/latest.tar.bz2"
iocage exec "${JAIL_NAME}" "tar -xf /tmp/latest.tar.bz2 -C /usr/local/www"

#chown & chmod
iocage exec "${JAIL_NAME}" "chown -R ${USER}:${GROUP} /usr/local/www"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/www"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/www/nextcloud"

#for SYSRC_NAME in "${SYSRC}"; do
#  iocage exec "${JAIL_NAME}" sysrc "${SYSRC_NAME}_enable"=yes
#done
iocage exec "${JAIL_NAME}" "sysrc nginx_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc mysql_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc php_fpm_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc redis_enable=yes"


iocage exec "${JAIL_NAME}" "service mysql-server start"
iocage exec "${JAIL_NAME}" "service nginx start"
iocage exec "${JAIL_NAME}" "service php-fpm start"
iocage exec "${JAIL_NAME}" "service redis start"

iocage exec "${JAIL_NAME}" "cp /mnt/repo/post_install.sh /root"
iocage exec "${JAIL_NAME}" "chmod +x /root/post_install.sh"
#iocage exec "${JAIL_NAME}" "/root/post_install.sh"
