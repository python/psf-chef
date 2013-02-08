default_action :install

attribute :name, :name_attribute => true
attribute :version, :kind_of => String, :required => true
attribute :config_template, :kind_of => String
attribute :service_template, :kind_of => String
attribute :frontend, :kind_of => String, :default => '[*]:8443'
attribute :backend, :kind_of => String, :default => '[127.0.0.1]:8000'
attribute :pem_file, :kind_of => [String, Array], :required => true
attribute :tls, :equal_to => [true, false], :default => true
attribute :ssl, :equal_to => [true, false], :default => false
attribute :ciphers, :kind_of => String, :default => ''
attribute :prefer_server_ciphers, :equal_to => [true, false], :default => false
attribute :ssl_engine, :kind_of => String, :default => ''
attribute :workers, :kind_of => Integer, :default => 1
attribute :backlog, :kind_of => Integer, :default => 100
attribute :keepalive, :kind_of => Integer, :default => 3600
attribute :chroot, :kind_of => String, :default => ''
attribute :user, :kind_of => String, :default => ''
attribute :group, :kind_of => String, :default => ''
attribute :quiet, :equal_to => [true, false], :default => false
attribute :syslog, :equal_to => [true, false], :default => false
attribute :syslog_facility, :kind_of => String, :default => 'daemon'
attribute :daemon, :equal_to => [true, false], :default => false
attribute :write_ip, :equal_to => [true, false], :default => false
attribute :write_proxy, :equal_to => [true, false], :default => false
attribute :proxy_proxy, :equal_to => [true, false], :default => false

def resource_name
  if self.name != 'stud'
    "stud-#{self.name}"
  else
    'stud'
  end
end
