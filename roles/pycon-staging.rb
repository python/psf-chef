name "pycon-staging"
description "Staging for Pycon website"
# Owner: Diana Clark
run_list [
  "recipe[psf-pycon::app]"
]
