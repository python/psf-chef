name "apt"
description "Ubuntu APT Server"
run_list [
    "recipe[reprepro]",
]
