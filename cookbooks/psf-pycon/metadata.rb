maintainer       "Ernest W. Durbin III"
maintainer_email "ewdurbin@gmail.com"
license          "Apache 2.0"
description      "Configuration for us.pycon.org staging and production"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.40"

depends "sudo"
depends "application_python"
depends "application_nginx"
depends "nodejs"
depends "git"
depends "firewall"
depends "cron"
