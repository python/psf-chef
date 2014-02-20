name 'pydotorg-staging-web'
description 'Staging role for pydotorg web machines'
override_attributes(
  'pydotorg-redesign' => {
    'env' => 'staging'
  }
)
run_list [
    'recipe[pydotorg-redesign::default]',
    'recipe[pydotorg-redesign::base-rules]',
    'recipe[pydotorg-redesign::web-rules]'
]
