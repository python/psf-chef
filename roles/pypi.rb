name "pypi"
description "Python package index server"
run_list [
    'recipe[rsyslog::server]',
    'recipe[psf-pypi::pgbouncer]',
    'recipe[psf-pypi::logging]',
]
override_attributes({
  :rsyslog => {
    :port => 51450,
    :user => "root",
    :group => "admin",
    :log_dir => "/var/log/rsyslog",
    :per_host_dir => "%HOSTNAME%",
    :high_precision_timestamps => true,
  },
})
