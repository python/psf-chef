attribute :name, :name_attribute => true
attribute :password, :kind_of => [String, NilClass]
attribute :hash, :equal_to => %{plain md5 crypt}, :default => 'md5'

def password_hash
  case self.hash
  when 'plain'
    self.password
  when 'md5'
    require 'digest/md5'
    'md5' + Digest::MD5.hexdigest(self.password + self.name)
  when 'crypt'
    raise 'Not implemented'
  end
end
