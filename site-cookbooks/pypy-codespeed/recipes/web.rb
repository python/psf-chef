application "speed.pypy.org" do
    path "/srv/speed.pypy.org"
    repository "https://github.com/alex/codespeed.git"
    revision "pypy"
    migrate true
    packages ["libpq-dev", "git-core", "mercurial", "subversion"]

    django do
        requirements "examples/requirements.txt"
        # TODO: write this
        settings_template "settings.py.erb"
        debug false
        database do
            engine "postgresql_psycopg2"
            database data_bag_item("secrets", "postgres")["pypy-codespeed"]["database"]
            hostname data_bag_item("secrets", "postgres")["pypy-codespeed"]["hostname"]
            username data_bag_item("secrets", "postgres")["pypy-codespeed"]["user"]
            password data_bag_item("secrets", "postgres")["pypy-codespeed"]["password"]
        end
    end
end
