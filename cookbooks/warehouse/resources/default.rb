default_action :install

attribute :name, :name_attribute => true
attribute :python, :kind_of => String, :default => "python"
attribute :path, :kind_of => String, :default => "/srv/warehouse"
attribute :virtualenv, :kind_of => String
attribute :user, :kind_of => String, :default => 'warehouse'
attribute :group, :kind_of => String, :default => 'warehouse'
attribute :version, :kind_of => String
attribute :domains, :kind_of => Array, :default => []
attribute :database, :kind_of => String
attribute :environment, :kind_of => Hash, :default => {}
attribute :debug, :kind_of => [TrueClass, FalseClass], :default => false
attribute :packages, :kind_of => Hash
attribute :settings, :kind_of => Hash
attribute :create_user, :kind_of => [TrueClass, FalseClass], :default => true
attribute :fastly, :kind_of => [TrueClass, FalseClass], :default => false
attribute :cache, :kind_of => Hash, :default => {}
attribute :paths, :kind_of => Hash, :default => {}
attribute :urls, :kind_of => Hash, :default => {}
attribute :redis, :kind_of => String
attribute :site_name, :kind_of => String, :default => "Warehouse"
