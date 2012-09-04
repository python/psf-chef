name "coverity"
description "Coverity scan server"
# Owner: Christian Heimes <christian@cheimes.de>

run_list [
  "recipe[build-essential]",
]
