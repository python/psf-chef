# sysctl "net.ipv4.ip_nonlocal_bind" do
#   value 1
# end

include_recipe 'haproxy'

haproxy_section 'python' do
  source 'haproxy.cfg.erb'
  variables({
    :pypi_servers => search(:node, 'roles:pypi AND tags:active'),
    :wiki_servers => search(:node, 'roles:wiki AND tags:active'),
    :pypy_home_servers => search(:node, 'roles:pypy-home AND tags:active'),
  })
end
