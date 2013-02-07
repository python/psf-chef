Steps to build this custom stud package:

1. sudo aptitude install build-essential git libev-dev ruby1.9.1 ruby1.9.1-dev
2. git clone https://github.com/bumptech/stud.git
3. Edit Makefile so that PREFIX=/usr
4. make
5. sudo make install
6. sudo gem install fpm
7. fpm -s dir -t deb -n stud -v 19a7f1 -C / -d 'libc6 >= 2.4' -d 'libev4 >= 1:4.04' -d 'libssl1.0.0 >= 1.0.0' /usr/bin/stud /usr/share/man/man8/stud.8
