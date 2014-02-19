name 'pydotorg-prod-web'
description 'Production role for pydotorg web machines'
override_attributes(
  'pydotorg-redesign' => {
    'env' => 'prod'
  }
)
run_list [
    'recipe[pydotorg-redesign::default]',
    'recipe[pydotorg-redesign::crons]',
    'recipe[pydotorg-redesign::base-rules]',
    'recipe[pydotorg-redesign::web-rules]'
]
