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
  options = self.options.split(',').inject({}) do |pair, memo|
    key, val = pair.split('=', 2)
    memo[key] = val
    memo
  end
  unless self.exclude.empty?
    rsync_long_args = options['rsync_long_args'] || (options['+rsync_long_args'] ||= '')
    rsync_long_args << ' ' unless rsync_long_args.empty?
    rsync_long_args << self.exclude.map{|path| "--exclude=#{path}"}.join(' ')
  end
  options.map{|key, val| "#{key}=#{val}"}.join(',')
end
