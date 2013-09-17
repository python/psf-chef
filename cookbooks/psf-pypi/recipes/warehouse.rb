# Get our Database settings
database = data_bag_item("secrets", "postgres")["pypi"]

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
    :database => database["database"],
    :host => "localhost",
    :username => database["user"],
    :password => database["password"],
    :engine => "postgresql_psycopg2",
  })
end
