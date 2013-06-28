maintainer       "Noah Kantrowitz"
maintainer_email "noah@coderanger.net"
license          "Apache 2.0"
description      "Configuration related to the PSF load balancers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.4"

depends "heartbeat"
#depends "jn_sysctl"
depends "haproxy"
depends "stud"
