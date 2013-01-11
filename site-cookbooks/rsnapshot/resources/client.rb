default_action :install
actions :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :server_role, :kind_of => String, :default => nil

