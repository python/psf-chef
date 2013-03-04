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
        # Override the resource to add a "python_interpreter" option.
        class ApplicationPydotorgDjango < ApplicationPythonDjango
            attribute :python_interpreter, :default => '/usr/bin/python'
        end
    end
    class Provider
        class ApplicationPydotorgDjango < ApplicationPythonDjango
            # Now override install_packages to pick up the attribute above. I
            # didn't copypasta the bit that installs packages from a  packages
            # attribute since I'm not using that here, it's all in requirements.
            def install_packages
                python_virtualenv new_resource.virtualenv do
                    path new_resource.virtualenv
                    interpreter new_resource.python_interpreter
                    action :create
                end
            end

            # Workaround for http://tickets.opscode.com/browse/CHEF-2784 -
            # Chef sets LC_ALL=C on execute, which causes pip to fail if
            # there's anything encoded in the setup.py. Like above the entire
            # before_migrate action isn't copied since I don't need all the
            # flexibility.
            def action_before_migrate
                if new_resource.requirements
                  Chef::Log.info("Installing using requirements file: #{new_resource.requirements}")
                  pip_cmd = ::File.join(new_resource.virtualenv, 'bin', 'pip')
                  execute "#{pip_cmd} install --source=#{Dir.tmpdir} -r #{new_resource.requirements}" do
                    cwd new_resource.release_path
                    environment "LC_ALL" => ENV['LANG']
                  end
                else
                  Chef::Log.debug("No requirements file found")
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

# pip really doesn't like being run without a good env encoding, so fix that.
ENV['LANG'] = "en_US.UTF-8"

# It's a secret to everyone.
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
    end

    gunicorn do
        # Have to manually specify the application and virtualenv config since
        # we're not using `app_module :django.`
        app_module "pydotorg.wsgi:application"
        virtualenv "/srv/redesign.python.org/shared/env"
    end
end

