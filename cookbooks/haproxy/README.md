Steps to build this custom HAProxy package:

1. sudo aptitude install build-essential libev-dev ruby1.9.1 ruby1.9.1-dev libpcre3-dev
2. wget http://haproxy.1wt.eu/download/1.5/src/devel/haproxy-1.5-dev22.tar.gz
3. tar -xvf haproxy-1.5-dev22.tar.gz
4. cd haproxy-1.5-dev22
5. sudo make all install TARGET=linux2628 PREFIX=/usr USE_PCRE=1 USE_STATIC_PCRE=1
6. sudo gem install fpm
7. fpm -s dir -t deb -n haproxy -v 1.5-dev22 -C / -d 'libc6 >= 2.5' /usr/sbin/haproxy /usr/share/man/man1/haproxy.1 /usr/doc/haproxy
