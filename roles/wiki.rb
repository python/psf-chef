name "wiki"
description "Python wiki site"
# Owner: Noah Kantrowitz <noah@coderanger.net> (I guess? Sigh)

run_list [
  'recipe[psf-moin]',
  'role[postfix-relay]',
  'recipe[monitoring::client]',
]
