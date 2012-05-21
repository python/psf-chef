sysctl "net.ipv4.ip_nonlocal_bind" do
  value 1
end

include_recipe "haproxy"
