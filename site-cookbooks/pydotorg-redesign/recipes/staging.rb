include_recipe 'python'

#
# The site uses Python 3.3, which we need to install from the "deadsnakes"
# PPA. This requires installing the PPA, then using it to install Python 3.3.
#

package "python-software-properties" do
    action :install
end

execute "activate deadsnakes ppa" do
    command "add-apt-repository ppa:fkrull/deadsnakes && aptitude update"
    creates "/etc/apt/sources.list.d/fkrull-deadsnakes-precise.list"
end

%w{build-essential python3.3 python3.3-dev postgresql-client-9.1 libpq-dev}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

#
# Now here's our application
#

secrets = data_bag_item("secrets", "redesign.python.org")

application "redesign.python.org" do
  path "/srv/redesign.python.org"
  repository "https://github.com/proevo/pythondotorg.git"
  revision "master"
  migrate true

  django do
    requirements "requirements.txt"
    collectstatic "collectstatic --noinput"
    environment "SECRET_KEY" => secrets["secret_key"],
                "DATABASE_URL" => secrets["database_url"]
  end

  gunicorn do
    app_module :django
    environment "SECRET_KEY" => secrets["secret_key"],
                "DATABASE_URL" => secrets["database_url"]
  end
end
