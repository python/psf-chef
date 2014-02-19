firewall_rule 'http' do
  protocol :tcp
  port 80
  action :allow
end
