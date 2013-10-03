# Get our Database settings
database = data_bag_item("secrets", "postgres")

# Get our secrets
secrets = data_bag_item("secrets", "pypi")

apt_repository "deadsnakes" do
    uri "http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "FF3997E83CD969B409FB24BC5BB92C09DB82666C"
end

package "python3.3-dev" do
  action :upgrade
end

warehouse "pypi" do
  python "python3.3"
  path "/opt/warehouse"

  packages ({
    "raven" => :latest,
  })

  environment ({
    "SENTRY_DSN" => secrets["sentry"]["dsn"],
  })

  fastly true
  cache ({
    "browser" => {
      "simple" => 900,
      "packages" => 900,
    },
    "varnish" => {
      "simple" => 86400,
      "packages" => 86400,
    },
  })

  paths ({
    "packages" => "/data/packages",
  })

  domains node["warehouse"]["domains"]
  database database["pypi"]["url"]
end
