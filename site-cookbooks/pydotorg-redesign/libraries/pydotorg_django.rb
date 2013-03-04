#
# Override the python/django application resource to take a
# python_interpreter option. Python 3 dudes.
#
# Code mostly by coderanger, thanks!
#

class Chef
  class Resource
    class ApplicationPydotorgDjango < ApplicationPythonDjango
      attribute python_interpreter, :default => '/usr/bin/python'
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
