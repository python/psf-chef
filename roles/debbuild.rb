name "debbuild"
description "Ubuntu APT Server"
run_list [
    "recipe[reprepro]",
    "recipe[psf-pypi::build]",
]
