name "pypi"
description "Python package index server"
run_list [
    'recipe[rsyslog::server]',
    'recipe[psf-pypi::pgbouncer]',
    'recipe[psf-pypi::logging]',
    # 'recipe[psf-pypi::pypi]',
]
override_attributes({
  :pypi => {
    :admins => [
        "richardjones@optushome.com.au",
        "martin@v.loewis.de",
        "jannis@leidel.info",
    ],
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
