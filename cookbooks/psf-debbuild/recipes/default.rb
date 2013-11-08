# Put our python-virtualenv package into reprepro
cookbook_file "python-virtualenv_1.10.1-1_all.deb" do
  path "/tmp/python-virtualenv_1.10.1-1_all.deb"
  action :create_if_missing
end

reprepro_deb "/tmp/python-virtualenv_1.10.1-1_all.deb"

# Put our dh-virtualenv package into reprepro
cookbook_file "dh-virtualenv_0.6_all.deb" do
  path "/tmp/dh-virtualenv_0.6_all.deb"
  action :create_if_missing
end

reprepro_deb "/tmp/dh-virtualenv_0.6_all.deb"
