default_action :install

attribute :name, :name_attribute => true
attribute :path, :kind_of => String, :default => "/srv/warehouse"
attribute :virtualenv, :kind_of => String
attribute :user, :kind_of => String, :default => 'warehouse'
attribute :group, :kind_of => String, :default => 'warehouse'
attribute :version, :kind_of => String
attribute :domains, :kind_of => Array, :default => []
attribute :secret_key, :kind_of => String
attribute :database, :kind_of => Hash
attribute :environment, :kind_of => Hash, :default => {}
attribute :debug, :kind_of => [TrueClass, FalseClass], :default => false
attribute :packages, :kind_of => Hash
attribute :installed_apps, :kind_of => Array
attribute :settings, :kind_of => Hash
attribute :create_user, :knife_of => [TrueClass, FalseClass], :default => true
