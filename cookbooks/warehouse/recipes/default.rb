# Make sure that the Postgresql Client library is installed
include_recipe "postgresql"

# Make sure that virtualenv is installed
include_recipe "python::virtualenv"

# Make sure supervisor is available to us
include_recipe "supervisor"

# Make sure Nginx is installed
include_recipe "nginx"

# Make sure Node.js is installed
include_recipe "nodejs::install_from_binary"

# Make sure lessc is installed
execute "install_lessc" do
  command "npm install -g less"
end

# Make sure libffi-dev is installed
package "libffi-dev"

# Make sure envdir is installed
package "daemontools"
