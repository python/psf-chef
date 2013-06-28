Steps to build this custom stud package:

Note that we are using a fork off the bumptech repo, this is for SNI support with wildcards.
See https://github.com/bumptech/stud/pull/126 for details. Make sure you rev the second
component of the version number (2, below) each time.

1. sudo aptitude install build-essential git libev-dev ruby1.9.1 ruby1.9.1-dev
2. git clone https://github.com/firebase/stud.git
2.5 git checkout ef1745b7bfbac9eee9045ca9d90487c763b21490
3. Edit Makefile so that PREFIX=/usr
4. make
5. sudo make install
6. sudo gem install fpm
7. fpm -s dir -t deb -n stud -v 0.3-2-ef1745 -C / -d 'libc6 >= 2.4' -d 'libev4 >= 1:4.04' -d 'libssl1.0.0 >= 1.0.0' /usr/bin/stud /usr/share/man/man8/stud.8
