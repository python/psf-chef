firewall_rule 'elasticsearch-from-prod-web' do
  protocol :tcp
  port_range 9200..9400
  source '140.211.10.95'
  action :allow
end

firewall_rule 'elasticsearch-from-staging-web' do
  protocol :tcp
  port_range 9200..9400
  source '140.211.10.77'
  action :allow
end
