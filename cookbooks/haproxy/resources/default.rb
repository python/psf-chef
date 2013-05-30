default_action :install
actions :reload

attribute :name, :name_attribute => true
attribute :config_template, :kind_of => String
attribute :service_template, :kind_of => String
attribute :config_directory, :kind_of => String, :default => '/etc/haproxy'
attribute :user, :kind_of => String, :default => 'haproxy'
attribute :group, :kind_of => String, :default => 'haproxy'

def resource_name
  if self.name != 'haproxy'
    "haproxy-#{self.name}"
  else
    'haproxy'
  end
end
