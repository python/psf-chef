name "base"
description "Base recipes for all nodes"
run_list [
  "recipe[chef-client::cron]",
  "recipe[chef-client::delete_validation]",
  "recipe[user::data_bag]",
]
override_attributes({
  :authorization => {
    :sudo => {
      :include_sudoers_d => true,
    },
  },
  :chef_client => {
    :cron => {
      :minute => "*/30",
      :hour => "*",
    }
  },
  :user => {
    :ssh_keygen => false,
  },
})
