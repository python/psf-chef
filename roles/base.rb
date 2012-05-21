name "base"
description "Base recipes for all nodes"
run_list "recipes[users::data_bag]"
override_attributes({
  :authorization => {
    :sudo => {
      :include_sudoers_d => true,
    },
  },
  :users => {
    :ssh_keygen => false,
  },
})
