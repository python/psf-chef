name "monitoring"
description "Nagios and etc"
# Owners: Noah Kantrowitz
run_list [
  "recipe[psf-monitoring::server]",
]
