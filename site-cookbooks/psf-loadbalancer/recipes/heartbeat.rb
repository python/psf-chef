
include_recipe "heartbeat"

secrets = data_bag_item('secrets', 'heartbeat')

heartbeat "psf-loadbalancer" do
  authkeys secrets['secrets'][0]
  resources "140.211.10.69"
end
