#/bin/csh
FS_NEXTCLOUD_CONF=/mnt/system_cache/NextCloud_conf
FS_NEXTCLOUD_DATA=/mnt/system_cache/NextCloud_data
FS_MYSQL_DATA=/mnt/system_cache/NextCloud_mysql

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
#iocage exec "${JAIL_NAME}" "service redis stop"

echo -e "\nApp folders rename in order to mount correctly.\n"
#rename inside folders in orderto create folders for mounts
iocage exec "${JAIL_NAME}" "mv /root /root_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/www/nextcloud/apps /usr/local/www/nextcloud/apps_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/www/nextcloud/apps-pkg /usr/local/www/nextcloud/apps-pkg_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/www/nextcloud/config /usr/local/www/nextcloud/config_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/www/nextcloud/themes /usr/local/www/nextcloud/themes_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/www/nextcloud/data /usr/local/www/nextcloud/data_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/etc/nginx /usr/local/etc/nginx_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d_tmp"
#iocage exec "${JAIL_NAME}" "mv /usr/local/etc/redis /usr/local/etc/redis_tmp"
iocage exec "${JAIL_NAME}" "mv /usr/local/etc/mysql /usr/local/etc/mysql_tmp"
iocage exec "${JAIL_NAME}" "mv /var/db/mysql /var/db/mysql_tmp"


echo -e "\nFolder and user creation, permission and mounting\n"
#iocage folder creation and mounting
#mkdir outside the jail

mkdir -p "${FS_NEXTCLOUD_CONF}"/home_root
mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud
mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/apps
mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/apps-pkg
mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/config
mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/themes
mkdir -p "${FS_NEXTCLOUD_CONF}"/nextcloud/data
mkdir -p "${FS_NEXTCLOUD_CONF}"/nginx
mkdir -p "${FS_NEXTCLOUD_CONF}"/nginx/conf.d
mkdir -p "${FS_NEXTCLOUD_CONF}"/php-fpm.d
#mkdir -p "${FS_NEXTCLOUD_CONF}"/redis
mkdir -p "${FS_NEXTCLOUD_CONF}"/mysql

mkdir -p "${FS_NEXTCLOUD_CONF}"/repo
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/apps
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/apps-pkg
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/config
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/themes
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nextcloud/data
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nginx
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/nginx/conf.d
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/php-fpm.d
mkdir -p "${FS_NEXTCLOUD_CONF}"/repo/mysql

#mkdir inside the jail
echo -e "\nFolder creation inside the jail\n"
iocage exec "${JAIL_NAME}" mkdir -p /root
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/apps
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/apps-pkg
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/config
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/themes
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/www/nextcloud/data
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/nginx
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/nginx/conf.d
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/php-fpm.d
iocage exec "${JAIL_NAME}" mkdir -p /usr/local/etc/mysql
iocage exec "${JAIL_NAME}" mkdir -p /var/db/mysql
iocage exec "${JAIL_NAME}" mkdir -p /mnt/repo

#zfs set primarycache=metadata system_cache/NextCloud_data

echo -e "\nMounting app folders.\n"
#mounting fs
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/home_root" "/root" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/apps" "/usr/local/www/nextcloud/apps" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/apps-pkg" "/usr/local/www/nextcloud/apps-pkg" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/config" "/usr/local/www/nextcloud/config" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nextcloud/themes" "/usr/local/www/nextcloud/themes" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_DATA}" "/usr/local/www/nextcloud/data" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/nginx" "/usr/local/etc/nginx" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/php-fpm.d" "/usr/local/etc/php-fpm.d" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/mysql" "/usr/local/etc/mysql" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_MYSQL_DATA}/" "/var/db/mysql" nullfs rw 0 0
iocage fstab -a "${JAIL_NAME}" "${FS_NEXTCLOUD_CONF}/repo" "/mnt/repo" nullfs rw 0 0

echo -e "\nCopy jail files if the mounted directory is empty. If not, old data will be used.\n"
if [ $(iocage exec "${JAIL_NAME}" "ls /root | wc -l") -gt "0" ]; then
  echo "Copy of /mnt/repo/home_root"
  iocage exec "${JAIL_NAME}" "cp -pr /root_tmp/* /mnt/repo/home_root"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /root_tmp/.* /mnt/repo/home_root"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -pr /root_tmp/* /root"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /root_tmp/.* /root"
  sleep 2
  #iocage exec "${JAIL_NAME}" "rm -r /root_tmp"
fi

if [ $(iocage exec "${JAIL_NAME}" "ls /usr/local/www/nextcloud/apps | wc -l") -gt "0" ]; then
  echo "Copy of /usr/local/www/nextcloud/apps"
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/www/nextcloud/apps_tmp/* /usr/local/www/nextcloud/apps"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/www/nextcloud/apps_tmp/.* /usr/local/www/nextcloud/apps"
  sleep 2
  #iocage exec "${JAIL_NAME}" "rm -r /usr/local/www/nextcloud/apps_tmp"
fi

if [ $(iocage exec "${JAIL_NAME}" "ls /usr/local/www/nextcloud/apps-pkg | wc -l") -gt "0" ]; then
  echo "Copy of /usr/local/www/nextcloud/apps-pkg"
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/www/nextcloud/apps-pkg_tmp/* /usr/local/www/nextcloud/apps-pkg"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/www/nextcloud/apps-pkg_tmp/.* /usr/local/www/nextcloud/apps-pkg"
  sleep 2
  #iocage exec "${JAIL_NAME}" "rm -r /usr/local/www/nextcloud/apps-pkg_tmp"
fi

if [ $(iocage exec "${JAIL_NAME}" "ls /usr/local/www/nextcloud/themes | wc -l") -gt "0" ]; then
  echo "Copy of /usr/local/www/nextcloud/themes"
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/www/nextcloud/themes_tmp/* /usr/local/www/nextcloud/themes"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/www/nextcloud/themes_tmp/.* /usr/local/www/nextcloud/themes"
  sleep 2
  #iocage exec "${JAIL_NAME}" "rm -r /usr/local/www/nextcloud/themes_tmp"
fi

if [ $(iocage exec "${JAIL_NAME}" "ls /usr/local/www/nextcloud/data | wc -l") -gt "0" ]; then
  echo "Copy of /usr/local/www/nextcloud/data"
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/www/nextcloud/data_tmp/* /usr/local/www/nextcloud/data"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/www/nextcloud/data_tmp/.* /usr/local/www/nextcloud/data"
  sleep 2
  #iocage exec "${JAIL_NAME}" "rm -r /usr/local/www/nextcloud/apps_tmp"
fi

if [ $(iocage exec "${JAIL_NAME}" "ls /usr/local/etc/nginx | wc -l") -gt "0" ]; then
  echo "Copy of /usr/local/etc/nginx"
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/etc/nginx_tmp/nginx.conf /mnt/repo/nginx"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/etc/nginx_tmp/conf.d/* /mnt/repo/nginx/conf.d"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/etc/nginx_tmp/* /usr/local/etc/nginx"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/etc/nginx_tmp/.* /usr/local/etc/nginx"
  sleep 2
  #iocage exec "${JAIL_NAME}" "rm -r /usr/local/etc/nginx_tmp"
fi

if [ $(iocage exec "${JAIL_NAME}" "ls /usr/local/etc/php-fpm.d" | wc -l) -gt "0" ]; then
  echo "Copy of /usr/local/etc/php-fpm.d"
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/etc/php-fpm.d_tmp/* /mnt/repo/php-fpm.d"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/etc/php-fpm.d_tmp/* /usr/local/etc/php-fpm.d"
  sleep 2
  #iocage exec "${JAIL_NAME}" "rm -r /usr/local/etc/php-fpm.d_tmp"
fi
if [ $(iocage exec "${JAIL_NAME}" "ls /usr/local/etc/mysql | wc -l") -gt "0" ]; then
  echo "Copy of /usr/local/etc/mysql"
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/etc/mysql_tmp/* /mnt/repo/mysql"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/etc/mysql_tmp/.* /mnt/repo/mysql"
  sleep 2
  iocage exec "${JAIL_NAME}" "cp -pr /usr/local/etc/mysql_tmp/* /usr/local/etc/mysql"
  iocage exec "${JAIL_NAME}" "cp -p /usr/local/etc/mysql_tmp/.* /usr/local/etc/mysql"
  #iocage exec "${JAIL_NAME}" "rm -r /usr/local/etc/mysql_tmp"
fi
if [ $(iocage exec "${JAIL_NAME}" "ls /var/db/mysql" | wc -l) -gt "0" ]; then
  echo "Copy of /var/db/mysql"
  iocage exec "${JAIL_NAME}" "cp -pr /var/db/mysql_tmp/* /var/db/mysql"
  iocage exec "${JAIL_NAME}" "cp -p /var/db/mysql_tmp/.* /var/db/mysql"
  #iocage exec "${JAIL_NAME}" "rm -r /var/db/mysql_tmp"
fi

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

