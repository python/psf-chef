default_action :install

attribute :name, :kind_of => String, :name_attribute => true
attribute :command, :kind_of => String, :required => true
