attribute :name, :name_attribute => true
attribute :dbname, :kind_of => [String, NilClass], :default => false # false used as a sentinel value
attribute :host, :kind_of => String, :required => true
attribute :port, :kind_of => [String, Integer], :default => 5432
attribute :user, :kind_of => [String, NilClass]
attribute :password, :kind_of => [String, NilClass]

def to_config
  config_line = []
  config_line << "dbname=#{self.dbname || self.name}" unless self.dbname.nil?
  config_line << "host=#{self.host} port=#{self.port}"
  if self.user
    config_line << "user=#{self.user}"
    config_line << "password=#{self.password}" if self.password
  end
  config_line.join(' ')
end
