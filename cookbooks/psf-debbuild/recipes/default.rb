# Get our secrets
secrets = data_bag_item("secrets", "debbuild")

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

# Install Jenkins
jenkins node['jenkins']['server']['home']
jenkins_plugin "git"
jenkins_plugin "debian-package-builder"
jenkins_plugin "ws-cleanup"
jenkins_plugin "postbuildscript"

sudo "jenkins" do
  user      "jenkins"
  nopasswd  true
end

# Install git
package "git"

# Install equivs
package "equivs"

# Install Twine
python_pip "twine" do
  action :upgrade
end

# Install PyPI Credentials
file "/#{node['jenkins']['server']['home']}/.pypirc" do
  owner "jenkins"
  group "jenkins"
  mode "0600"

  backup false

  content <<-eos
[distutils]
index-servers =
    pypi

[pypi]
repository:https://pypi.python.org/pypi
username:#{secrets['pypi_username']}
password:#{secrets['pypi_password']}
eos
end

directory "/#{node['jenkins']['server']['home']}/.ssh" do
    owner "jenkins"
    group "jenkins"
end

file "/#{node['jenkins']['server']['home']}/.ssh/id_rsa" do
  owner "jenkins"
  group "jenkins"
  mode "0600"

  backup false

  content secrets["ssh_key"]
end
