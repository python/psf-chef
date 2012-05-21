name "loadbalancer"
description "PSF load balancer"
run_list [
  "recipe[psf-loadbalancer::heartbeat]",
]
