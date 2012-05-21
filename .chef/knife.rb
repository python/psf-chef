begin
  require 'librarian/chef/integration/knife'
rescue LoadError
  Chef::Log.fatal "Please gem install librarian"
  exit 1
end

# Some sane defaults 
log_level                :info
log_location             STDOUT
node_name                ENV["CHEF_USER"] || ENV["USER"]
client_key               File.expand_path("~/.chef/#{node_name}.pem")

# Load a user config file if present
user_config = File.expand_path("~/.chef/knife.rb")
if File.exist?(user_config)
  Chef::Log.info("Loading user-specific configuration from #{user_config}")
  instance_eval(IO.read(user_config), user_config, 1)
end

# Project-specific settings, can't be overriden by the user
current_dir = File.dirname(__FILE__)
validation_client_name   "psf-validator"
validation_key           File.join(current_dir, "psf-validator.pem")
chef_server_url          "https://api.opscode.com/organizations/psf"
cache_type               "BasicFile"
cache_options             :path => File.expand_path("~/.chef/checksums")
cookbook_path            [Librarian::Chef.install_path, File.expand_path("../../site-cookbooks", __FILE__)]

if !File.exists?(validation_key)
  Chef::Log.error "validator key not found, you will be unable to bootstrap new nodes. Please contact infrastructure@python.org for a copy if needed"
end
