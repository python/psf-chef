name 'pydotorg-prod-es'
description 'Production role for python.org elasticsearch instances'
run_list [
  'recipe[apt]',
  'recipe[java]',
  'recipe[pydotorg-redesign::elasticsearch]'
]
