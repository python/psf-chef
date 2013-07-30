# Warehouse User and Group
default["warehouse"]["user"] = "warehouse"
default["warehouse"]["group"] = "warehouse"

# Warehouse Source Location
default["warehouse"]["source"]["repository"] = "https://github.com/pypa/pypi.python.org.git"
default["warehouse"]["source"]["revision"] = "master"

# Warehouse Base Path
default["warehouse"]["path"] = "/srv/warehouse"

# Warehouse Runtime Configuration
default["warehouse"]["conf"]["debug"] = false
default["warehouse"]["conf"]["app"]["port"] = 8000
default["warehouse"]["conf"]["app"]["wsgi"] = "warehouse.wsgi"

# Warehouse Domain Setup
default["warehouse"]["domains"] = ["pypi.python.org"]
