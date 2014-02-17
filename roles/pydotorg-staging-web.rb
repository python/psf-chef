name 'pydotorg-staging-web'
description 'Staging role for pydotorg web machines'
override_attributes(
  'pydotorg-redesign' => {
    'env' => 'staging'
  }
)
run_list [
    'recipe[pydotorg-redesign::default]',
]
