# Make sure that the Postgresql Client library is installed
include_recipe "postgresql"

# Make sure that virtualenv is installed
include_recipe "python::virtualenv"

# Make sure supervisor is available to us
include_recipe "supervisor"

# Make sure Nginx is installed
include_recipe "nginx"
