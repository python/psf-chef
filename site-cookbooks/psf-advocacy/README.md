aptitude install apache2
create /etc/apache2/sites-available/advocacy
a2enmod rewrite
a2dissite 000-default
a2ensite advocacy
mkdir /log
mkdir /data/advocacy (was /data/www/advocacy)
rsync -avz ximinez.python.org:/data/www/advocacy /data

