default_action :backup
actions :remove

attribute :directory, :kind_of => String, :name_attribute => true
attribute :options, :kind_of => String, :default => ''
