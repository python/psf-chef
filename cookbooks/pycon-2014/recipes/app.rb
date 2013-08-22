secrets = data_bag_item("secrets", "pycon-2014")
is_production = tagged?('production')
if is_production
  db = data_bag_item("secrets", "postgres")["pycon2014"]
  app_name = "us.pycon.org"
else
  db = data_bag_item("secrets", "postgres")["pycon2014-staging"]
  app_name = "staging-pycon.python.org"
end

include_recipe "nodejs::install_from_binary"
include_recipe "git"
include_recipe "firewall"

execute "install_lessc" do
  command "npm install -g less@1.3.3"
end

git "/srv/pycon-archive" do
  repository "https://github.com/python/pycon-archive.git"
  revision "master"
end

application app_name do
  path "/srv/staging-pycon.python.org"
  repository "git://github.com/caktus/pycon.git"
  revision is_production ? "production" : "staging"
  packages ["libpq-dev", "git-core", "libjpeg8-dev"]
  migration_command "/srv/staging-pycon.python.org/shared/env/bin/python manage.py syncdb --migrate --noinput"
  migrate true
  environment "SECRET_KEY" => secrets["secret_key"], "GRAYLOG_HOST" => secrets["graylog_host"], "IS_PRODUCTION" => "#{is_production}", "DB_NAME" => db["database"], "DB_HOST" => db["hostname"], "DB_PORT" => "", "DB_USER" => db["user"], "DB_PASSWORD" => db["password"], "EMAIL_HOST" => "mail.python.org", "MEDIA_ROOT" => "/srv/staging-pycon.python.org/shared/media/"

  before_deploy do
    directory "/srv/staging-pycon.python.org/shared/media" do
      owner "root"
      group "root"
      action :create
    end
  end

  before_symlink do
    execute "/srv/staging-pycon.python.org/shared/env/bin/python manage.py compress --force" do
      user "root"
      cwd release_path
    end
  end

  django do
    requirements "requirements/project.txt"
    settings_template "local_settings.py.erb"
    local_settings_file "local_settings.py"
    collectstatic "collectstatic --noinput"
    settings :secret_key => secrets["secret_key"], :graylog_host => secrets["graylog_host"], :is_production => is_production
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
    template 'nginx.conf.erb' # Remove this once /2014/ is the default
    hosts ['localhost'] if Chef::Config[:solo] # For testing in Vagrant
    application_server_role is_production ? "pycon-2014" : "pycon-2014-staging"
    server_name [node['fqdn'], 'staging-pycon.python.org', 'us.pycon.org']
    static_files({
      "/2014/site_media/static" => "site_media/static",
      "/2014/site_media/media" => "/srv/staging-pycon.python.org/shared/media",
      "/2013" => "/srv/pycon-archive/2013",
      "/2012" => "/srv/pycon-archive/2012",
      "/2011" => "/srv/pycon-archive/2011",
    })
    application_port 8080
  end

end

cron "staging-pycon account expunge" do
  hour "0"
  minute "0"
  command "cd /srv/staging-pycon.python.org/current && /srv/staging-pycon.python.org/shared/env/bin/python manage.py expunge_deleted"
end

firewall 'ufw' do
  action :enable
end

firewall_rule 'ssh' do
  port 22
  protocol :tcp
  action :allow
end

firewall_rule 'http_our_net' do
  port 80
  source '140.211.10.64/26'
  direction :in
  action :allow
end
