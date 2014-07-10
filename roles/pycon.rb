name "pycon"
description "Production Pycon website"
# Owner: Diana Clark
run_list [
  "recipe[psf-pycon::app]"
]
