#!/bin/sh

# Enable the service
sysrc -f /etc/rc.conf nginx_enable="YES"
sysrc -f /etc/rc.conf mysql_enable="YES"
sysrc -f /etc/rc.conf php_fpm_enable="YES"

cp -r /mnt/repo/nginx/conf.d/nextcloud.conf.template /usr/local/etc/nginx/conf.d/
cp -r /mnt/repo/nginx/conf.d/nextcloud.conf.checksum /usr/local/etc/nginx/conf.d/
# Install fresh nextcloud.conf if user hasn't upgraded
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
set NCPASS=`cat /root/ncpassword´

if [ -e "/root/.mysql_secret" ] ; then
  # Mysql > 57 sets a default PW on root
  set TMPPW=`cat /root/.mysql_secret | grep -v "^#"`
  echo "SQL Temp Password: ${TMPPW}"

  # Configure mysql
  mysql -u root -p"${TMPPW}" --connect-expired-password <<-EOF
  ALTER USER 'root'@'localhost' IDENTIFIED BY "${PASS}";
  CREATE USER \'"${USER}"\'@'localhost' IDENTIFIED BY "${PASS}";
  GRANT ALL PRIVILEGES ON "${DB}".* TO \'"${USER}"\'@'localhost' WITH GRANT OPTION;
  GRANT ALL PRIVILEGES ON "${DB}".* TO \'"${USER}"\'@'localhost';
  FLUSH PRIVILEGES;
  -EOF

  # Make the default log directory
  mkdir /var/log/zm
  chown www:www /var/log/zm
  
  else
  # Mysql <= 56 does not

  # Configure mysql
  mysql -u root <<-EOF
  UPDATE mysql.user SET Password=PASSWORD('${PASS}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
  
  CREATE USER '${USER}'@'localhost' IDENTIFIED BY '${PASS}';
  GRANT ALL PRIVILEGES ON *.* TO '${USER}'@'localhost' WITH GRANT OPTION;
  GRANT ALL PRIVILEGES ON ${DB}.* TO '${USER}'@'localhost';
  FLUSH PRIVILEGES;
  EOF
fi

# If on NAT, we need to use the HOST address as the IP
if [ -e "/etc/iocage-env" ] ; then
        IOCAGE_PLUGIN_IP=$(cat /etc/iocage-env | grep HOST_ADDRESS= | cut -d '=' -f 2)
        echo "Using NAT Address: $IOCAGE_PLUGIN_IP"
fi

# Fix the config file to include apps-pkg which is FreeBSD's way of keeping pkg apps
# away from user installed
cp /mnt/repo/nextcloud/config/config.php /usr/local/www/nextcloud/config/config.php
chown www:www /usr/local/www/nextcloud/config/config.php

#Use occ to complete Nextcloud installation
su -m www -c "php /usr/local/www/nextcloud/occ maintenance:install --database=\"mysql\" --database-name=\"nextcloud\" --database-user=\"$USER\" --database-pass=\"$PASS\" --database-host=\"localhost\" --admin-user=\"$NCUSER\" --admin-pass=\"$NCPASS\" --data-dir=\"/usr/local/www/nextcloud/data\""
a\"" 
