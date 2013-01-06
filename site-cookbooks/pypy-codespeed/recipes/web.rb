application "speed.pypy.org" do
  path "/srv/speed.pypy.org"
  repository "https://github.com/alex/codespeed.git"
  revision "pypy"
  migrate true
  packages ["libpq-dev", "git-core", "mercurial", "subversion"]

  django do
    requirements "examples/requirements.txt"
    packages ["psycopg2"]
    # TODO: write this
    settings_template "settings.py.erb"
    debug false
    collectstatic "collectstatic --noinput"
    database do
      engine "postgresql_psycopg2"
      database data_bag_item("secrets", "postgres")["pypy-codespeed"]["database"]
      hostname data_bag_item("secrets", "postgres")["pypy-codespeed"]["hostname"]
      username data_bag_item("secrets", "postgres")["pypy-codespeed"]["user"]
      password data_bag_item("secrets", "postgres")["pypy-codespeed"]["password"]
    end
  end

  nginx_load_balancer do
    application_server_role "pypy-codespeed"
    static_files "/static" => "example/sitestatic/"
  end
end
