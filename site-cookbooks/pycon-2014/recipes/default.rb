db = data_bag_item("secrets", "postgres")["pycon2014"]

application "staging-pycon.python.org" do
  path "/srv/staging-pycon.python.org"
  repository "git://github.com/pinax/symposion.git"
  migrate true

  django do
    requirements "requirements.txt"
    packages ["psycopg2", "gunicorn"]
    settings_template "settings.py.erb"
    local_settings_file "symposion_project/settings.py"
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
    application_server_role "pycon2014"
    server_name [node['fqdn'], 'staging-pycon.python.org']
    static_files "/static" => "example/sitestatic/"
    application_port 8080
  end
end
