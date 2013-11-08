# Put our python-virtualenv package into reprepro
cookbook_file "python-virtualenv_1.10.1-1_all.deb" do
  path "/tmp/python-virtualenv_1.10.1-1_all.deb"
  action :create_if_missing
end

reprepro_deb "/tmp/python-virtualenv_1.10.1-1_all.deb"
