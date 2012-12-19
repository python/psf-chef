
cron "ntp resync" do
  hour "0"
  minute "0"
  command "service ntp restart"
end
