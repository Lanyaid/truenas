#/bin/csh
#iocage jail creation
JAIL_NAME="nextcloud"
RELEASE="11.4"
IP_ADDR="172.16.0.2"
MASK_ADDR="30"
DEFAULT_ROUTER="172.16.0.1"
PORT_GUEST="80"
PORT_HOST="8415"
DHCP="0"
PHP_PACKAGES="php74 php74-bz2 php74-ctype php74-curl php74-dom php74-exif php74-fileinfo php74-filter php74-gd php74-iconv php74-intl php74-json php74-ldap php74-mbstring php74-opcache php74-openssl php74-pdo php74-pdo_mysql php74-pecl-APCu php74-pecl-imagick php74-pecl-redis php74-posix php74-session php74-simplexml php74-xml php74-xmlreader php74-xmlwriter php74-xsl php74-zip php74-zlib php74-bcmath php74-gmp"
PACKAGES="nano wget ca_root_nss nginx mariadb104-server redis tree sudo git ${PHP_PACKAGES}"
SYSRC="nginx mysql php_fpm redis"
SERVICES=$( echo -e "nginx\nmysql-server\nphp-fpm\nredis" )
 
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
  nat_forwards="tcp(${PORT_GUEST}:${PORT_HOST})" \
  mac_prefix="428d5c" \
  vnet0_mac="428d5c6cb0ba 428d5c6cb0bb" \
  host_hostname="${JAIL_NAME}" \
  host_hostuuid="${JAIL_NAME}" \
  allow_mount_devfs="1" \
  allow_raw_sockets="1" \
  jail_zfs_dataset="iocage/jails/${JAIL_NAME}/data"


echo -e "\nRestarting jail ${JAIL_NAME}\n################################\n"

#restarting jail
iocage restart "${JAIL_NAME}"

echo -e "\nFolder and user creation, permission and mounting\n"
#iocage folder creation and mounting
#mkdir outside the jail

mkdir -p /mnt/system_cache/NextCloud_conf/nextcloud
mkdir -p /mnt/system_cache/NextCloud_conf/nginx
mkdir -p /mnt/system_cache/NextCloud_conf/nginx/conf.d
mkdir -p /mnt/system_cache/NextCloud_conf/php-fpm.d
mkdir -p /mnt/system_cache/NextCloud_conf/mysql
mkdir -p /mnt/system_cache/NextCloud_conf/nextcloud/apps
mkdir -p /mnt/system_cache/NextCloud_conf/nextcloud/apps-pkg
mkdir -p /mnt/system_cache/NextCloud_conf/nextcloud/config
mkdir -p /mnt/system_cache/NextCloud_conf/nextcloud/data
mkdir -p /mnt/system_cache/NextCloud_conf/nextcloud/themes

#mkdir inside the jail

iocage exec "${JAIL_NAME}" mkdir -p /root
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/apps
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/apps-pkg
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/config
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/data
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/themes
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/nginx
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/nginx/conf.d
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/php-fpm.d
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/mysql
iocage exec "${JAIL_NAME}" mkdir -p /var/db/mysql
iocage exec "${JAIL_NAME}" mkdir -p /mnt/repo

#zfs set primarycache=metadata system_cache/NextCloud_data

#create user and group
#iocage exec "${JAIL_NAME}" pw groupadd -n "${GROUP}" -g "${GID}"
iocage exec "${JAIL_NAME}" "pw groupadd -n ${GROUP2} -g ${GID2}"
#iocage exec "${JAIL_NAME}" pw useradd -n "${USER}" -u "${UID}" -d /nonexistent -s /usr/sbin/nologin
iocage exec "${JAIL_NAME}" "pw useradd -n ${USER2} -u ${UID2} -d /nonexistent -s /usr/sbin/nologin"
#iocage exec "${JAIL_NAME}" pw groupmod "${GROUP}" -m "${USER}"
iocage exec "${JAIL_NAME}" "pw groupmod ${GROUP2} -m ${USER2}"

#chown & chmod
iocage exec "${JAIL_NAME}" "chown -R ${USER}:${GROUP} /usr/local/www"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/www"
iocage exec "${JAIL_NAME}" "chown -R ${USER2}:${GROUP2} /var/db/mysql"
iocage exec "${JAIL_NAME}" "chmod 770 /var/db/mysql"

#mounting fs
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/nextcloud/apps" "/usr/local/www/nextcloud/apps" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/nextcloud/apps-pkg" "/usr/local/www/nextcloud/apps-pkg" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/nextcloud/config" "/usr/local/www/nextcloud/config" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/nextcloud/themes" "/usr/local/www/nextcloud/themes" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_data" "/usr/local/www/nextcloud/data" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/home_root" "/root" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/nginx" "/usr/local/etc/nginx" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/php-fpm.d" "/usr/local/etc/php-fpm.d" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_mysql" "/var/db/mysql" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/mysql" "/usr/local/etc/mysql" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "/mnt/system_cache/NextCloud_conf/repo" "/mnt/repo" nullfs rw 0 0

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

iocage exec "${JAIL_NAME}" "sysrc nginx_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc mysql_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc php_fpm_enable=yes"
iocage exec "${JAIL_NAME}" "sysrc redis_enable=yes"


iocage exec "${JAIL_NAME}" "service mysql-server start"
iocage exec "${JAIL_NAME}" "service nginx start"
iocage exec "${JAIL_NAME}" "service php-fpm start"
iocage exec "${JAIL_NAME}" "service redis start"

iocage exec "${JAIL_NAME}" "cp -r /mnt/repo/nginx/conf.d/nextcloud.conf.template /usr/local/etc/nginx/conf.d/"
iocage exec "${JAIL_NAME}" "cp -r /mnt/repo/nginx/conf.d/nextcloud.conf.checksum /usr/local/etc/nginx/conf.d/"
iocage exec "${JAIL_NAME}" "cp -r /mnt/repo/nginx/nginx.conf /usr/local/etc/nginx/"
iocage exec "${JAIL_NAME}" "cp /mnt/repo/post_install.sh /root"
iocage exec "${JAIL_NAME}" "chmod +x /root/post_install.sh"
iocage exec "${JAIL_NAME}" "/root/post_install.sh"

iocage restart "${JAIL_NAME}"

