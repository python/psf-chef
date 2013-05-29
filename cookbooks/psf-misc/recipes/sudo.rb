include_recipe "sudo"

sudo "env_keep" do
  template "sudo_env_keep.erb"
end
