include_recipe "collectd::client_graphite"

%w(disk load cpu memory interface swap).each do |plug|
  collectd_plugin plug
end
