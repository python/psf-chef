
cron "ntpdate" do
  hour "0"
  minute "0"
  command "/usr/sbin/ntpd -qgx"
end
