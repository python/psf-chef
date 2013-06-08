# Global PyPI Configuration
default["pypi"]["user"] = "pypi"
default["pypi"]["group"] = "root"

# PyPI Web Application Configuration
default["pypi"]["admins"] = []

default["pypi"]["database"]

default["pypi"]["web"]["debug"] = false

default["pypi"]["web"]["dirs"]["data"] = "/data"
default["pypi"]["web"]["dirs"]["files"] = "packages"
default["pypi"]["web"]["dirs"]["docs"] = "packagedocs"
default["pypi"]["web"]["dirs"]["key"] = "pypi"

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

