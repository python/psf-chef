db = data_bag_item("secrets", "postgres")["pycon2014"]
secrets = data_bag_item("secrets", "pycon-2014")

include_recipe "nodejs::install_from_binary"

execute "install_lessc" do
  command "npm install -g less@1.3.3"
end

application "staging-pycon.python.org" do
  path "/srv/staging-pycon.python.org"
  repository "git://github.com/caktus/pycon.git"
  revision "staging"
  packages ["libpq-dev", "git-core"]
  migration_command "/srv/staging-pycon.python.org/shared/env/bin/python manage.py syncdb --migrate --noinput"
  migrate true

  before_symlink do
    "/srv/staging-pycon.python.org/shared/env/bin/python manage.py compress --force"
  end

  django do
    requirements "requirements/project.txt"
    settings_template "local_settings.py.erb"
    local_settings_file "local_settings.py"
    collectstatic "collectstatic --noinput"
    settings :secret_key => secrets["secret_key"], :graylog_host => secrets["graylog_host"]
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
    static_files "/2014/site_media/static" => "site_media/static"
    application_port 8080
  end
  
end

cron "staging-pycon account expunge" do
  hour "0"
  minute "0"
  command "cd /srv/staging-pycon.python.org/current && /srv/staging-pycon.python.org/shared/env/bin/python manage.py expunge_deleted"
end
