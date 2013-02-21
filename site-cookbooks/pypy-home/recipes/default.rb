include_recipe 'mercurial'

application "pypy.org" do
  path "/srv/pypy.org"
  repository "https://bitbucket.org/pypy/pypy.org"
  revision 'tip'
  scm_provider Chef::Provider::Mercurial

  nginx_load_balancer do
    template "nginx.conf.erb"
    server_name [node['fqdn'], 'pypy.org', 'www.pypy.org']
    static_files "/" => "/srv/pypy.org/current"
  end
end
