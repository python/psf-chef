# Get our Database settings
database = data_bag_item("secrets", "postgres")

# Get our secrets
secrets = data_bag_item("secrets", "pypi")

package "python3-dev" do
  action :upgrade
end

warehouse "pypi" do
  path "/srv/warehouse"

  packages ({
    "raven" => :latest,
  })

  installed_apps [
    "raven.contrib.django.raven_compat",
  ]

  environment ({
    "SENTRY_DSN" => secrets["sentry"]["dsn"],
  })

  domains node["warehouse"]["domains"]
  secret_key secrets["warehouse"]["secret_key"]
  database ({
    :database => database["pypi"]["database"],
    :host => "localhost",
    :username => database["pypi"]["user"],
    :password => database["pypi"]["password"],
    :engine => "postgresql_psycopg2",
  })
end

warehouse "testpypi" do
  path "/srv/testwarehouse"

  packages ({
    "raven" => :latest,
  })

  installed_apps [
    "raven.contrib.django.raven_compat",
  ]

  environment ({
    "SENTRY_DSN" => secrets["sentry"]["dsn"],
  })

  domains ["test.preview.pypi.python.org"]
  secret_key secrets["warehouse"]["secret_key"]
  database ({
    :database => database["testpypi"]["database"],
    :host => "localhost",
    :username => database["testpypi"]["user"],
    :password => database["testpypi"]["password"],
    :engine => "postgresql_psycopg2",
  })
end
