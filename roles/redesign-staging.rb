name "redesign-staging"
description "Staging server for web redesign project"
# Owners: Jacob Kaplan-Moss <jacob@jacobian.org>, Frank Wiles <frank@revsys.com>
run_list [
    "recipe[pydotorg-redesign::staging]",
    "recipe[pydotorg-redesign::elasticsearch]"
]
