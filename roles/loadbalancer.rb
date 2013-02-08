name "loadbalancer"
description "PSF load balancer"
run_list [
  "recipe[psf-loadbalancer::heartbeat]",
  "recipe[psf-loadbalancer::haproxy]",
  "recipe[psf-loadbalancer::stud]",
]
