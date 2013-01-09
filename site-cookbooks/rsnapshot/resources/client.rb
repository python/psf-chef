default_action :install
actions :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :ssh_key, :kind_of => String
