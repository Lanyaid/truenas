#/bin/csh
FS_BASE=/mnt/system_cache
FS_JAILS_BASE=${FS_BASE}/iocage/jails
FS_NEXTCLOUD_CONF="${FS_BASE}"/NextCloud_conf
FS_NEXTCLOUD_DATA="${FS_BASE}"/NextCloud_data
FS_MYSQL_DATA="${FS_BASE}"/NextCloud_mysql

#iocage jail variables
JAIL_NAME="nextcloud"

USER="www"
UID="80"
GROUP="www"
GID="80"
USER2="mysql"
UID2="88"
GROUP2="mysql"
GID2="88"

#update jail and package install
echo -e "\nJail update and packages install\n"
iocage exec "${JAIL_NAME}" "pkg-static install -y pkg"
iocage exec "${JAIL_NAME}" "pkg update"
iocage exec "${JAIL_NAME}" "pkg upgrade"

#stop services 
echo -e "\nServices stop\n"
iocage exec "${JAIL_NAME}" "service nginx stop"
iocage exec "${JAIL_NAME}" "service php-fpm stop"
iocage exec "${JAIL_NAME}" "service mysql-server stop"


echo -e "\nFolder and user creation, permission, copy, move and mounting\n"
#iocage folder creation and mounting
#mkdir outside the jail

#mkdir -p "${FS_NEXTCLOUD_CONF}"/home_root
mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud
#mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/apps
#mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/apps-pkg
#mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/config
#mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/themes
#mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/data
#mkdir -p "${FS_NEXTCLOUD_CONF}"/nginx
#mkdir -p "${FS_NEXTCLOUD_CONF}"/nginx/conf.d
#mkdir -p "${FS_NEXTCLOUD_CONF}"/php-fpm.d
#mkdir -p "${FS_NEXTCLOUD_CONF}"/redis
#mkdir -p "${FS_NEXTCLOUD_CONF}"/mysql

mkdir -p "${FS_NEXTCLOUD_CONF}"/repo
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/home_root
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/apps
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/apps-pkg
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/config
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/themes
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/data
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nginx
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nginx/conf.d
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/php-fpm.d
#mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/mysql

echo -e "\nApp folders rename in order to mount correctly.\n"
#rename of the folders from outside the jail, in order to mount them inside after.
#if the folders are not empty, we don't copy or move nothing, it's because we have data of a previous version
#of nextcloud and we want to re-install this version.

#if [ -e "${FS_NEXTCLOUD_CONF}/root" ]; then
#  if [ $(ls "${FS_NEXTCLOUD_CONF}/root" | wc -l) -gt "0" ]; then
#    echo "${FS_NEXTCLOUD_CONF}/root is not empty, we try to use it to mount."
#    else
#    echo "${FS_NEXTCLOUD_CONF}/root is empty, we try to copy ${FS_JAILS_BASE}/${JAIL_NAME}/root/root into it."
#    mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/root" "${FS_NEXTCLOUD_CONF}"
#  fi
#  else
#  echo "${FS_NEXTCLOUD_CONF}/root does not exist, we try to move it from ${FS_JAILS_BASE}/${JAIL_NAME}/root/root."
#  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/root" "${FS_NEXTCLOUD_CONF}"
#fi

if [ -e "${FS_NEXTCLOUD_CONF}/root" ]; then
  echo "${FS_NEXTCLOUD_CONF}/root exist, we try to use it to mount."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/root" "${FS_JAILS_BASE}/${JAIL_NAME}/root/root_old"
  else
  echo "${FS_NEXTCLOUD_CONF}/root does not exist, we try to copy it from ${FS_JAILS_BASE}/${JAIL_NAME}/root/root."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/root" "${FS_NEXTCLOUD_CONF}"
fi

if [ -e "${FS_NEXTCLOUD_CONF}/nextcloud/apps" ]; then
    echo "${FS_NEXTCLOUD_CONF}/nextcloud/apps exist, we try to use it to mount."
    mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps" "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps_old"
    else
    echo "${FS_NEXTCLOUD_CONF}/nextcloud/apps does not exist, we try to copy it from ${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps."
    mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps" "${FS_NEXTCLOUD_CONF}/nextcloud/"
fi

if [ -e "${FS_NEXTCLOUD_CONF}/nextcloud/apps-pkg" ]; then
  echo "${FS_NEXTCLOUD_CONF}/nextcloud/apps-pkg exist, we try to use it to mount."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps-pkg" "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps-pkg_old"
  else
  echo "${FS_NEXTCLOUD_CONF}/nextcloud/apps-pkg does not exist, we try to copy it from ${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps-pkg."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/apps-pkg" "${FS_NEXTCLOUD_CONF}/nextcloud/"
fi

if [ -e "${FS_NEXTCLOUD_CONF}/nextcloud/config" ]; then
  echo "${FS_NEXTCLOUD_CONF}/nextcloud/config exist, we try to use it to mount."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/config" "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/config_old"
  else
  echo "${FS_NEXTCLOUD_CONF}/nextcloud/config does not exist, we try to copy it from ${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/config."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/config" "${FS_NEXTCLOUD_CONF}/nextcloud/"
fi

if [ -e "${FS_NEXTCLOUD_CONF}/nextcloud/themes" ]; then
  echo "${FS_NEXTCLOUD_CONF}/nextcloud/themes is not empty, we try to use it to mount."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/themes" "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/themes_old"
  else
  echo "${FS_NEXTCLOUD_CONF}/nextcloud/themes is empty, we try to move ${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/themes into it."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/themes" "${FS_NEXTCLOUD_CONF}/nextcloud/"
fi

if [ $(ls "${FS_NEXTCLOUD_DATA}" | wc -l) -gt "0" ]; then
  echo "${FS_NEXTCLOUD_DATA} is not empty, we try to use it to mount."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/data" "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/data_old"
  else
  echo "${FS_NEXTCLOUD_DATA} is empty, we try to move it from ${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/data."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/www/nextcloud/data" "${FS_NEXTCLOUD_DATA}"
fi

if [ -e "${FS_MYSQL_DATA}/mysql" ]; then
  echo "${FS_MYSQL_DATA} exist, we try to use it to mount."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/var/db/mysql" "${FS_JAILS_BASE}/${JAIL_NAME}/root/var/db/mysql_old"
  else
  echo "${FS_MYSQL_DATA} does not exist, we try to copy it from ${FS_JAILS_BASE}/${JAIL_NAME}/root/var/db/mysql."
  mv "${FS_JAILS_BASE}/${JAIL_NAME}/root/var/db/mysql" "${FS_MYSQL_DATA}"
fi

if [ -e "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/nginx.conf" ]; then
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/nginx.conf exist, we don't need to bck up."
  else 
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/nginx.conf does not exist, we bck it."
  cp "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/nginx.conf" "${FS_NEXTCLOUD_CONF}/repo/nginx/"
fi

if [ -e "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/conf.d" ]; then
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/conf.d exist, we don't need to bck up."
  else 
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/conf.d does not exist, we bck it."
  cp -pr "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/nginx/conf.d" "${FS_NEXTCLOUD_CONF}/repo/nginx/"
fi

if [ -e "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/php-fpm.d" ]; then
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/php-fpm.d exist, we don't need to bck up."
  else 
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/php-fpm.d does not exist, we bck it."
  cp -pr "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/php-fpm.d" "${FS_NEXTCLOUD_CONF}/repo/"
fi

if [ -e "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/mysql" ]; then
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/mysql exist, we don't need to bck up."
  else 
  echo "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/mysql does not exist, we bck it."
  cp -pr "${FS_JAILS_BASE}/${JAIL_NAME}/root/usr/local/etc/mysql" "${FS_NEXTCLOUD_CONF}/repo/"
fi

#mkdir inside the jail
echo -e "\nFolder creation inside the jail\n"
iocage exec "${JAIL_NAME}" mkdir -p /root
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/apps
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/apps-pkg
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/config
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/themes
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/data
iocage exec "${JAIL_NAME}" mkdir -p /var/db/mysql
iocage exec "${JAIL_NAME}" mkdir -p /mnt/repo

echo -e "\nMounting app folders.\n"
#mounting fs
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/root" "/root" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/apps" "/usr/local/www/nextcloud/apps" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/apps-pkg" "/usr/local/www/nextcloud/apps-pkg" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/config" "/usr/local/www/nextcloud/config" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/themes" "/usr/local/www/nextcloud/themes" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/repo" "/mnt/repo" nullfs rw 0 0

iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_DATA}/data" "/usr/local/www/nextcloud/data" nullfs rw 0 0

iocage fstab -a "${JAIL_NAME}" "${FS_MYSQL_DATA}/mysql" "/var/db/mysql" nullfs rw 0 0

#chown & chmod
echo "chown -R ${USER}:${GROUP} /usr/local/www"
iocage exec "${JAIL_NAME}" "chown -R ${USER}:${GROUP} /usr/local/www"
echo "chmod 770 /usr/local/www"
iocage exec "${JAIL_NAME}" "chmod 770 /usr/local/www"
echo "change permission for folders and files in nextcloud directory"
iocage exec "${JAIL_NAME}" "find /usr/local/www/nextcloud -type d -print0 | xargs -0 chmod 770"
iocage exec "${JAIL_NAME}" "find /usr/local/www/nextcloud -type f -print0 | xargs -0 chmod 660"

echo "chown -R ${USER2}:${GROUP2} /var/db/mysql"
iocage exec "${JAIL_NAME}" "chown -R ${USER2}:${GROUP2} /var/db/mysql"
echo "chmod 770 /var/db/mysql"
iocage exec "${JAIL_NAME}" "chmod 770 /var/db/mysql"
echo "change permission for folders and files in mysql directory"
iocage exec "${JAIL_NAME}" "find /var/db/mysql -type d -print0 | xargs -0 chmod 770"
iocage exec "${JAIL_NAME}" "find /var/db/mysql -type f -print0 | xargs -0 chmod 660"

#starting the services
iocage exec "${JAIL_NAME}" "service mysql-server start"
iocage exec "${JAIL_NAME}" "service php-fpm start"
iocage exec "${JAIL_NAME}" "service nginx start"
#iocage exec "${JAIL_NAME}" "service redis start"

#iocage exec "${JAIL_NAME}" "cp /mnt/repo/post_install.sh /root"
#iocage exec "${JAIL_NAME}" "chmod +x /root/post_install.sh"

