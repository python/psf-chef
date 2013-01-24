name "postfix-relay"
description "Utility role to install an outbound SMTP relay"
run_list [
  "recipe[postfix]",
]

override_attributes({
  :postfix => {
    :relayhost => 'mail.python.org',
  },
})
