#!/bin/sh

CPCONFIG=0
if [ -e "/usr/local/etc/nginx/conf.d/nextcloud.conf" ] ; then
  # Confirm the config doesn't have user-changes. Update if not
  if [ "$(md5 -q /usr/local/etc/nginx/conf.d/nextcloud.conf)" = "$(cat /usr/local/etc/nginx/conf.d/nextcloud.conf.checksum)" ] ; then
          CPCONFIG=1
  fi
  else
  CPCONFIG=1
fi

# Copy over the nginx config template
if [ "$CPCONFIG" = "1" ] ; then
  mv /usr/local/etc/nginx/conf.d/nextcloud.conf.template /usr/local/etc/nginx/conf.d/nextcloud.conf
  #md5 -q /usr/local/etc/nginx/conf.d/nextcloud.conf > /mnt/repo/nginx/conf.d/nextcloud.conf.checksum
fi
cp /mnt/repo/php-fpm.d/nextcloud.conf /usr/local/etc/php-fpm.d/
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
# Modify opcache settings in php.ini according to Nextcloud documentation (remove comment and set recommended value)
# https://docs.nextcloud.com/server/15/admin_manual/configuration_server/server_tuning.html#enable-php-opcache
sed -i '' 's/.*opcache.enable=.*/opcache.enable=1/' /usr/local/etc/php.ini
sed -i '' 's/.*opcache.enable_cli=.*/opcache.enable_cli=1/' /usr/local/etc/php.ini
sed -i '' 's/.*opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/' /usr/local/etc/php.ini
sed -i '' 's/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/' /usr/local/etc/php.ini
sed -i '' 's/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/' /usr/local/etc/php.ini
sed -i '' 's/.*opcache.save_comments=.*/opcache.save_comments=1/' /usr/local/etc/php.ini
sed -i '' 's/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=1/' /usr/local/etc/php.ini
# recommended value of 512MB for php memory limit (avoid warning when running occ)
sed -i '' 's/.*memory_limit.*/memory_limit=512M/' /usr/local/etc/php.ini
# recommended value of 10 (instead of 5) to avoid timeout
sed -i '' 's/.*pm.max_children.*/pm.max_children=10/' /usr/local/etc/php-fpm.d/nextcloud.conf
# Nextcloud wants PATH environment variable set.
echo "env[PATH] = $PATH" >> /usr/local/etc/php-fpm.d/nextcloud.conf

# Start the service
service nginx start 2>/dev/null
service php-fpm start 2>/dev/null
service mysql-server start 2>/dev/null

#https://docs.nextcloud.com/server/13/admin_manual/installation/installation_wizard.html do not use the same name for user and db
set USER="dbadmin"
set DB="nextcloud"
set NCUSER="ncadmin"

# Save the config values
echo "${DB}" > /root/dbname
echo "${USER}" > /root/dbuser
echo "${NCUSER}" > /root/ncuser
export LC_ALL=C
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/dbpassword
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/ncpassword
set PASS=`cat /root/dbpassword`
set NCPASS=`cat /root/ncpassword`
set TMPPW=`cat /root/.mysql_secret | grep -v "^#"`
echo "SQL Temp Password: ${TMPPW}"


# Fix the config file to include apps-pkg which is FreeBSD's way of keeping pkg apps
# away from user installed
cp /mnt/repo/nextcloud/config/config.php /usr/local/www/nextcloud/config/config.php
chown www:www /usr/local/www/nextcloud/config/config.php

#Use occ to complete Nextcloud installation
su -m www -c "php /usr/local/www/nextcloud/occ maintenance:install --database=\"mysql\" --database-name=\"nextcloud\" --database-user=\"$USER\" --database-pass=\"$PASS\" --database-host=\"localhost\" --admin-user=\"$NCUSER\" --admin-pass=\"$NCPASS\" --data-dir=\"/usr/local/www/nextcloud/data\""
su -m www -c "php /usr/local/www/nextcloud/occ config:system:set trusted_domains 1 --value=\"${IOCAGE_PLUGIN_IP}\""
su -m www -c "php /usr/local/www/nextcloud/occ db:add-missing-indices"

#workaround for occ (in shell just use occ instead of su -m www -c "....")
echo >> .cshrc
echo alias occ ./occ.sh >> .cshrc
echo 'su -m www -c php\ ``/usr/local/www/nextcloud/occ\ "$*"``' > ~/occ.sh
chmod u+x ~/occ.sh

#workaround for app-pkg
sed -i '' "s|false|true|g" /usr/local/www/nextcloud/config/config.php

# create sessions tmp dir outside nextcloud installation
mkdir -p /usr/local/www/nextcloud-sessions-tmp >/dev/null 2>/dev/null
chmod o-rwx /usr/local/www/nextcloud-sessions-tmp
chown -R www:www /usr/local/www/nextcloud-sessions-tmp
chown -R www:www /usr/local/www/nextcloud/apps-pkg

chmod -R o-rwx /usr/local/www/nextcloud

#updater needs this
chown -R www:www /usr/local/www/nextcloud

#restart the services to make sure we have pick up the new permission
service php-fpm restart 2>/dev/null
#nginx restarts to fast while php is not fully started yet
sleep 5
service nginx restart 2>/dev/null

echo "Database Name: $DB" > /root/PLUGIN_INFO
echo "Database User: $USER" >> /root/PLUGIN_INFO
echo "Database Password: $PASS" >> /root/PLUGIN_INFO

echo "Nextcloud Admin User: $NCUSER" >> /root/PLUGIN_INFO
echo "Nextcloud Admin Password: $NCPASS" >> /root/PLUGIN_INFO
