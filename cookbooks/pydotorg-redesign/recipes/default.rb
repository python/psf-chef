include_recipe 'python'
include_recipe 'java'

current_env = node['pydotorg-redesign']['env']

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
      self.resource_name = 'application_pydotorg_django'
    end
  end
  class Provider
    class ApplicationPydotorgDjango < ApplicationPythonDjango
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
            environment 'LC_ALL' => ENV['LANG']
          end
        end
      end

      # Skip generation of the settings file; the recipe does it using
      # the local_settings pattern which doesn't fit with our app.
      def action_before_deploy
        install_packages
      end
    end
  end
end

execute 'apt-key update' do
  command 'apt-key update'
  user 'root'
  action :nothing
end

#
# The site uses Python 3.3, which we need to install from the "deadsnakes"
# PPA. This requires installing the PPA, then using it to install Python 3.3.
#
# For some wacky reason I had to fire off apt-key update after adding this repo..
apt_repository 'deadsnakes' do
  uri           'http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu/'
  keyserver     'keyserver.ubuntu.com'
  key           'DB82666C'
  components    ['main']
  distribution  node['lsb']['codename']
  action        :add
  notifies :run, 'execute[apt-key update]', :immediately
end

dependencies = %w{
  build-essential
  git-core
  python3.3
  python3.3-dev
  postgresql-client-9.1
  libpq-dev
  rubygems
}

dependencies.each do |pkg|
  package pkg do
    action :upgrade
  end
end

gem_package 'bundler' do
  action :upgrade
end

# yui-compressor 2.4.6 has a nasty bug; install 2.4.7 from Quantal instead.
remote_file "#{Chef::Config[:file_cache_path]}/yui-compressor_2.4.7-1_all.deb" do
  source "http://ubuntu.media.mit.edu/ubuntu//pool/main/y/yui-compressor/yui-compressor_2.4.7-1_all.deb"
end

dpkg_package 'yui-compressor' do
  source "#{Chef::Config[:file_cache_path]}/yui-compressor_2.4.7-1_all.deb"
  action :install
end

package 'subversion' do
  action :install
end

# pip really doesn't like being run without a good env encoding, so fix that.
ENV['LANG'] = 'en_US.UTF-8'

# Work around the django target not understanding Python 3.3: as it turns out,
# the python_virtualenv resource (that the django application uses under the
# hood) doesn't check very hard that the virtualenv exists at any particular
# version. So we'll (ab)use that fact and create a Python 3.3 virtualenv; the
# django application provider will sorta silently pick that up and be happy.
%w{/srv/redesign.python.org /srv/redesign.python.org/shared}.each do |d|
  directory d do
    action :create
  end
end

python_virtualenv '/srv/redesign.python.org/shared/env' do
  interpreter 'python3.3'
  action :create
end

secrets = data_bag_item('secrets', 'pydotorg-redesign')
db = data_bag_item('secrets', 'postgres')["redesign-#{current_env}"]

application 'redesign.python.org' do
  path '/srv/redesign.python.org'
  repository 'git@github.com:proevo/pythondotorg.git'
  deploy_key secrets['deploy_key']
  revision 'master'
  packages ['libxml2-dev', 'libxslt-dev']

  pydotorg_django do
    requirements 'requirements.txt'
    migration_command "/srv/redesign.python.org/shared/env/bin/python manage.py syncdb --settings pydotorg.settings.#{current_env} --migrate --noinput"
  end

  before_migrate do
    # Create a settings file. Doing this instead of the settings
    # stuff built into the Django resource so that it fits with our app
    # better.
    template ::File.join(new_resource.release_path, 'pydotorg', 'settings', "#{current_env}.py") do
      source 'settings.py.erb'
      variables 'db' => db,
                'secret_key' => secrets['secret_key']
    end
  end

  before_symlink do
    execute 'bundle install --binstubs' do
      cwd new_resource.release_path
    end

    # We can't use the Django resource's collectstatic because of CHEF-2784
    # again (see above), so do it here by hand instead.
    python_cmd = ::File.join(new_resource.path, 'shared', 'env', 'bin', 'python')
    execute "#{python_cmd} manage.py collectstatic -v0 --noinput" do
      cwd new_resource.release_path
      environment 'LC_ALL' => ENV['LANG'],
                  'DJANGO_SETTINGS_MODULE' => "pydotorg.settings.#{current_env}"
    end
  end

  gunicorn do
    # We don't want to use app_module :django because we're using the
    # Django-1.4-style WSGI entry point. So we have to manually specify
    # the virtualenv again.
    app_module 'pydotorg.wsgi:application'
    virtualenv '/srv/redesign.python.org/shared/env'
    settings_template 'gunicorn.py.erb'
    environment 'DJANGO_SETTINGS_MODULE' => "pydotorg.settings.#{current_env}"
  end

  nginx_load_balancer do
    application_server_role "pydotorg-#{current_env}-web"
    server_name [node['fqdn'], 'preview.python.org']
    static_files '/static' => 'static-root',
                 '/images' => 'static-root/images'
    application_port 8080
  end
end

