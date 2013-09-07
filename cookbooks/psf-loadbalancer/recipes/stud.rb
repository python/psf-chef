directory '/var/lib/stud' do
  owner 'root'
  group 'root'
  mode '700'
end

domains = %w{pycon.org pythonhosted.org raspberry.io python.org}

# Force the owner and permissions to be safe
domains.each do |domain|
  file "/etc/ssl/private/#{domain}.pem" do
    owner 'root'
    group 'root'
    mode '600'
    only_if { ::File.exists?("/etc/ssl/private/#{domain}.pem") }
  end
end

stud 'stud' do
  version '0.3-2-ef1745'
  pem_file domains.map{|domain| "/etc/ssl/private/#{domain}.pem" }
  frontend '[*]:443'
  tls false
  ssl true
  ciphers 'ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AES:RSA+3DES:!ADH:!AECDH:!MD5'
  prefer_server_ciphers true
  user 'nobody'
  group 'nogroup'
  chroot '/var/lib/stud'
  syslog true
  write_proxy true
  workers 4
  backlog 500
end
