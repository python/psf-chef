name "elasticsearch"
description "Search Index Server"
run_list [
  "recipe[java]",
  "recipe[elasticsearch]",
  "recipe[psf-search]",
]
override_attributes({
  :elasticsearch => {
    :version => "0.90.6",
    :network => {
      :host => "127.0.0.1",
    },
  },
  :java => {
    :oracle => {
      "accept_oracle_download_terms" => true
    },
  },
})
