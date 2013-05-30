BACKUPS_KEYS = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA43FpT4Ig2p8QFo4QjaZ5NVwE7k45wzRPE8jCASiFgtIdcfCF/i/2nSphkapwiJCWFiT66Au48RJRP6HnRwadi0AxlKdun/iWcUPsIMlU6P2EefU4Ol8Vdgg6aTAaKVeLKto5+Z9FXGkd5BCU8QLmm/5F8qsckHmgV0cpeSCdl7rFHXSp4OJE3gTDKPY7rJVIdHZ8NkdV6L63Yd/encXotVddroPS+q92wr5nc/w8g16SpmXuIbwDbkS+sCkZY5N8ByYgq/Vcs1RtCnzvEEWmIwgz6JlZt1l8ISK9hpbNOZUDuWo5mVbGQRx0qCeLoDDWxI7TZRI6/lQbW4f0uwStww==",
]

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "755"
end

template "/root/.ssh/authorized_keys" do
  cookbook "user"
  source "authorized_keys.erb"
  owner "root"
  group "root"
  mode "644"
  variables :user => "root", :ssh_keys => BACKUPS_KEYS.map{|key| %Q{no-pty,no-agent-forwarding,no-X11-forwarding,no-port-forwarding,command="rsync --server --sender -lHogDtpre.i   --ignore-errors --numeric-ids --inplace . /" #{key}}}
end
