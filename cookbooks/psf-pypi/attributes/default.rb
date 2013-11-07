# Logging Configuration
default["pypi"]["cdn"]["logging"]["app_name"] = "pypi-cdn"
default["pypi"]["cdn"]["logging"]["process_script"] = "/data/pypi/tools/rsyslog-cdn.py"

# Warehouse Domain Setup
default["warehouse"]["domains"] = ["pypi.python.org"]

# Warehouse Elasticsearch Setup
default["warehouse"]["elasticsearch"]["hosts"] = []
