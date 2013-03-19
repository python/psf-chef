apt_repository 'collectd' do
  uri 'http://ppa.launchpad.net/vbulax/collectd5/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '013B9839'
end
