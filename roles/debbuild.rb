name "debbuild"
description "Ubuntu APT Server"
run_list [
    "recipe[reprepro]",
    "recipe[psf-debbuild]",
    "recipe[psf-debbuild::warehouse]",
]
override_attributes({
    :reprepro => {
        :enable_repository_on_host => true,
    },
})
