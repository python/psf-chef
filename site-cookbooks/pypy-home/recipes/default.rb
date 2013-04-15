include_recipe 'mercurial'

# Temporary workaround because the hg provider computes the target rev
# locally before pulling, so of course it is always the old. The right fix is
# to either always pull (lame) or use the hg API to enumerate hashes on the
# remote server. See http://stackoverflow.com/a/11900786/78722 for the latter.
if ::File.exists?('/srv/pypy.org/shared/cached-copy/.hg')
  execute 'hg pull' do
    user 'root'
    group 'root'
    cwd '/srv/pypy.org/shared/cached-copy'
  end

  execute 'hg checkout -C extradoc' do
    user 'root'
    group 'root'
    cwd '/srv/pypy.org/shared/cached-copy'
  end
end

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
