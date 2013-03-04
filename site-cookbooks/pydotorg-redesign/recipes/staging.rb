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
        app_module :django
    end
end

