db = data_bag_item("secrets", "postgres")["pycon2014"]

application "staging-pycon.python.org" do
  path "/srv/staging-pycon.python.org"
  repository "git://github.com/pinax/symposion.git"
  packages ["libpq-dev", "git-core", "mercurial", "subversion"]
  migrate true

  django do
    requirements "requirements.txt"
    packages ["psycopg2", "gunicorn"]
    settings_template "local_settings.py.erb"
    local_settings_file "symposion_project/local_settings.py"
    collectstatic "collectstatic --noinput"
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
    application_server_role "pycon-2014"
    server_name [node['fqdn'], 'staging-pycon.python.org']
    static_files "/site_media/static" => "symposion_project/site_media/static"
    application_port 8080
  end
end
