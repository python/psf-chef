name "pycon-2014"
description "Staging for Pycon 2014 website"
# Owner: Ernest W. Durbin III
run_list [
  "recipe[pycon-2014::app]"
]
