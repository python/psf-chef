include_recipe 'python'

#
# Override the python/django application resource to take a python_interpreter
# option. Python 3 dudes. This is a hack; it really shouldn't be here but in a
# library instead. However, libraries can't override LWRPs, so... here we are.
#
# Code mostly by coderanger, thanks!
#

class ::Chef
  class Resource
    class ApplicationPydotorgDjango < ApplicationPythonDjango
      attribute :python_interpreter, :default => '/usr/bin/python'
    end
  end
  class Provider
    class ApplicationPydotorgDjango < ApplicationPythonDjango
      def install_packages
        python_virtualenv new_resource.virtualenv do
          path new_resource.virtualenv
          interpreter new_resource.python_interpreter
          action :create
        end
        new_resource.packages.each do |name, ver|
          python_pip name do
            version ver if ver && ver.length > 0
            virtualenv new_resource.virtualenv
            action :install
          end
        end
      end
    end
  end
end

#
# The site uses Python 3.3, which we need to install from the "deadsnakes"
# PPA. This requires installing the PPA, then using it to install Python 3.3.
#

apt_repository "deadsnakes" do
    uri "http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
end

%w{build-essential git-core python3.3 python3.3-dev postgresql-client-9.1 libpq-dev}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

secrets = data_bag_item("secrets", "pydotorg-redesign")
db = data_bag_item("secrets", "postgres")["redesign-staging"]
database_url = "postgres://#{db["user"]}:#{db["password"]}@#{db["hostname"]}/#{db["database"]}"

application "redesign.python.org" do
    path "/srv/redesign.python.org"
    repository "git@github.com:proevo/pythondotorg.git"
    deploy_key secrets["deploy_key"]
    revision "master"
    environment "SECRET_KEY" => secrets["secret_key"],
                "DATABASE_URL" => database_url

    pydotorg_django do
        python_interpreter "python3.3"
        requirements "requirements.txt"
        collectstatic "collectstatic --noinput"
    end

    gunicorn do
        app_module "pydotorg.wsgi:application"
    end
end

