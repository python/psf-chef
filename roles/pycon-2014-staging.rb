name "pycon-2014-staging"
description "Staging for Pycon 2014 website"
# Owner: Diana Clark
run_list [
  "recipe[pycon-2014::app]"
]
