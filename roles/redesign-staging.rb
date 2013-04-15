name "redesign-staging"
description "Staging server for web redesign project"
# Owner: Jacob Kaplan-Moss <jacob@jacobian.org>
run_list [
    "recipe[pydotorg-redesign::staging]"
]
