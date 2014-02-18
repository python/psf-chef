# sysctl "net.ipv4.ip_nonlocal_bind" do
#   value 1
# end

include_recipe 'haproxy'

haproxy_section 'python' do
  source 'haproxy.cfg.erb'
  variables({
    :pypi_servers => search(:node, 'roles:pypi AND tags:active'),
    :preview_pypi_servers => search(:node, 'roles:pypi AND tags:active'),
    :testpypi_servers => search(:node, 'roles:pypi AND tags:active'),
    :wiki_servers => search(:node, 'roles:wiki AND tags:active'),
    :pypy_home_servers => search(:node, 'roles:pypy-home AND tags:active'),
    :preview_servers => search(:node, 'roles:redesign-staging'),
    :pydotorg_servers => search(:node, 'roles:pydotorg-prod-web AND tags:active'),
    :raspberry_servers => search(:node, 'roles:rpi'),
    :evote_servers => search(:node, 'roles:evote'),
    :uspycon_servers => search(:node, 'roles:pycon-2014 AND tags:production'),
    :uspycon_staging_servers => search(:node, 'roles:pycon-2014-staging'),
  })
end
