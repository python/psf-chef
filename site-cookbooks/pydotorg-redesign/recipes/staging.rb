include_recipe 'python'

#
# The site uses Python 3.3, which we need to install from the "deadsnakes"
# PPA. This requires installing the PPA, then using it to install Python 3.3.
#

apt_repository "deadsnakes" do
    uri "http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
end

%w{build-essential python3.3 python3.3-dev postgresql-client-9.1 libpq-dev}.each do |pkg|
    package pkg do
        action :upgrade
    end
end
