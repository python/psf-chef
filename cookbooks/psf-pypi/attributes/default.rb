# Global PyPI Configuration
default["pypi"]["user"] = "pypi"
default["pypi"]["group"] = "pypi"
default["pypi"]["home"] = "/srv/pypi"

# Code locations and references
default["pypi"]["code"]["repository"] = "https://bitbucket.org/pypa/pypi"
default["pypi"]["code"]["reference"] = "tip"

# Setup Gunicorn
default["pypi"]["gunicorn"]["processes"] = 9
default["pypi"]["gunicorn"]["timeout"] = 15

# Setup Nginx
override["nginx"]["default_site_enabled"] = false

override["nginx"]["gzip"] = "on"
override["nginx"]["gzip_vary"] = "on"
override["nginx"]["gzip_types"] = [
  "application/javascript",
  "application/json",
  "application/x-javascript",
  "application/xml",
  "application/xml+rss",
  "image/x-icon",
  "text/css",
  "text/javascript",
  "text/plain",
  "text/xml",
]

# PyPI Web Application Configuration
default["pypi"]["admins"] = [
    "richardjones@optushome.com.au",
    "martin@v.loewis.de",
    "jannis@leidel.info",
]

default["pypi"]["database"]

default["pypi"]["web"]["debug"] = false

default["pypi"]["web"]["domains"] = [
    "pypi.python.org",
    "a.pypi.python.org",
]

default["pypi"]["web"]["hsts_seconds"] = nil


default["pypi"]["web"]["dirs"]["data"] = "/data"
default["pypi"]["web"]["dirs"]["files"] = "packages"
default["pypi"]["web"]["dirs"]["docs"] = "packagedocs"
default["pypi"]["web"]["dirs"]["key"] = "pypi"
default["pypi"]["web"]["dirs"]["static"] = "static"

default["pypi"]["web"]["pubsubhubbub"] = "http://pubsubhubbub.appspot.com/"

default["pypi"]["web"]["mail"]["host"] = "mail.python.org"
default["pypi"]["web"]["mail"]["email"] = "cheeseshop@python.org"
default["pypi"]["web"]["mail"]["reply"] = "cheeseshop@python.org"

default["pypi"]["web"]["urls"]["webui"] = "https://pypi.python.org/pypi"
default["pypi"]["web"]["urls"]["files"] = "https://pypi.python.org/packages/"
default["pypi"]["web"]["urls"]["docs"] = "https://pythonhosted.org/"
default["pypi"]["web"]["urls"]["python"] = "https://www.python.org/"

default["pypi"]["web"]["scripts"]["simple"] = "/simple"
default["pypi"]["web"]["scripts"]["simple_sign"] = "/serversig"

default["pypi"]["web"]["sshkeys_update"] = "/data/pypi/sshkeys_update"

default["pypi"]["web"]["rss"]["pypi"] = "/data/www/pypi/pypi_rss.xml"
default["pypi"]["web"]["rss"]["packages"] = "/data/www/pypi/pypi_packages_rss.xml"

default["pypi"]["passlib"]["schemes"] = ["bcrypt", "unix_disabled"]
default["pypi"]["passlib"]["deprecated"] = ["auto"]

default["pypi"]["fastly"]["api_domain"] = "https://api.fastly.com/"

# Logging Configuration
default["pypi"]["cdn"]["logging"]["app_name"] = "pypi-cdn"
default["pypi"]["cdn"]["logging"]["log_filename"] = "/var/log/pypi/cdn/access.log"

