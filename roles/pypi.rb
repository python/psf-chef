name "pypi"
description "Python package index server"
run_list [
    'recipe[psf-pypi::pgbouncer]',
    'recipe[rsyslog::server]',
]
override_attributes({
  :rsyslog => {
    :port => 51450,
    :per_host_dir => "%HOSTNAME%",
    :high_precision_timestamps => true,
  },
})
