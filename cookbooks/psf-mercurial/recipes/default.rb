# Apport conflicts with mercurial's demandimport, reported by __ap__

%w{apport python-apport}.each do |pkg|
  package pkg do
    action :remove
  end
end
