# Install the PyPy PPA
apt_repository "pypy" do
    uri "http://ppa.launchpad.net/pypy/ppa/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "2862D0785AFACD8C65B23DB0251104D968854915"
end

# Install PyPy
package "pypy"

# Install Invoke
python_pip "invoke" do action :upgrade end
python_pip "wheel" do action :upgrade end
