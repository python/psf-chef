default_action :install
actions :remove

attribute :name, :name_attribute => true
attribute :haproxy, :kind_of => String, :default => 'haproxy'
attribute :source, :kind_of => String, :required => true
attribute :cookbook, :kind_of => [String, NilClass]
attribute :variables, :kind_of => Hash, :default => {}

def haproxy_resource
  @haproxy_resource ||= resources("haproxy[#{self.haproxy}]")
rescue Chef::Exceptions::ResourceNotFound
  known_resources = run_context.resource_collection.select {|res| res.is_a? Chef::Resource::Haproxy}
  raise "Unknown HAProxy parent #{self.haproxy.inspect}. Did you mean one of: #{known_resources.join(', ')}"
end
