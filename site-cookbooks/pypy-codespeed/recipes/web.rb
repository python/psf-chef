db = data_bag_item("secrets", "postgres")["pypy-codespeed"]
secrets = data_bag_item("secrets", "pypy-codespeed")

application "speed.pypy.org" do
  path "/srv/speed.pypy.org"
  repository "https://github.com/alex/codespeed.git"
  revision "pypy"
  migrate true
  packages ["libpq-dev", "git-core", "mercurial", "subversion"]

  django do
    requirements "example/requirements.txt"
    packages ["psycopg2"]
    # TODO: write this
    settings_template "settings.py.erb"
    local_settings_file "example/settings.py"
    collectstatic "collectstatic --noinput"
    settings :secret_key => secrets["secret_key"]
    database do
      engine "postgresql_psycopg2"
      database db["database"]
      hostname db["hostname"]
      username db["user"]
      password db["password"]
    end
  end

  gunicorn do
    app_module :django
  end

  nginx_load_balancer do
    application_server_role "pypy-codespeed"
    server_name node['fqdn']
    static_files "/static" => "example/sitestatic/"
  end
end
