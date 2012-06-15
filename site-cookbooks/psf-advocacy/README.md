aptitude install apache2
create /etc/apache2/sites-available/advocacy
a2enmod rewrite
a2dissite 000-default
a2ensite advocacy
mkdir /data/advocacy (was /data/www/advocacy)
rsync -avz ximinez.python.org:/data/www/advocacy /data
apt-get install webalizer
rsync -avz ximinez.python.org:/data/webstats/advocacy /data/webstats
create /etc/webalizer/advocacy.conf
move logfiles to /var/log/apache2
change /etc/logrotate.d/apache2 to daily, four days
