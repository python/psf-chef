default_action :backup
actions :remove

attribute :directory, :kind_of => String, :name_attribute => true
attribute :options, :kind_of => String, :default => ''
attribute :_exclude, :kind_of => Array, :default => []
def exclude(*args)
  if args.length == 0
    self._exclude
  else
    args.flatten!
    self._exclude.push(*args)
  end
end

def full_options
  options_str = self.options.dup
  unless self.exclude.empty?
    options_str << ',' unless options_str.empty?
    options_str << self.exclude.map{|path| "+rsync_long_args=--exclude=#{path}"}.join(',')
  end
  options_str
end
