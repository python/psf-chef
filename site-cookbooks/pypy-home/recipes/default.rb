application "pypy.org" do
  path "/srv/pypy.org"
  repository "https://bitbucket.org/pypy/pypy.org"
  scm_provider Chef::Provider::Mercurial

  nginx_load_balancer do
    static_files "/" => ""
  end
end
