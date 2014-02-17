name 'pydotorg-prod-web'
description 'Production role for pydotorg web machines'
run_list [
    'recipe[pydotorg-redesign::prod]',
]
