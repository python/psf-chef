name             'psf-evote'
maintainer       'Noah Kantrowitz'
maintainer_email 'noah@coderanger.net'
license          'Apache 2'
description      'Installs/Configures Evote'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

depends 'git'
depends 'python'
depends 'gunicorn'
depends 'supervisor'
