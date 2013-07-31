name "pypi"
description "Python package index server"
run_list [
    'recipe[rsyslog::server]',
    'recipe[psf-pypi::pgbouncer]',
    'recipe[psf-pypi::logging]',
    'recipe[psf-pypi::pypi]',
    'recipe[warehouse]',
]
override_attributes({
  :warehouse => {
    :domains => ["next.pypi.python.org"],
  },
  :pypi => {
    :web => {
      :database => {
        :hostname => "localhost",
      },
    },
  },
  :rsyslog => {
    :port => 51450,
    :user => "root",
    :group => "admin",
    :log_dir => "/var/log/rsyslog",
    :per_host_dir => "%HOSTNAME%",
    :high_precision_timestamps => true,
  },
})
