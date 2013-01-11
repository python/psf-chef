rsnapshot_client 'rsnapshot' do
  server_role node['rsnapshot']['client']['server_role']
end
