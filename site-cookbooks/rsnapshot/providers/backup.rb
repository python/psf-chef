action :backup do
  node.set['rsnapshot_backups'] ||= {}
  node.set['rsnapshot_backups'][new_resource.directory] = {
    'directory' => new_resource.directory,
    'options' => new_resource.full_options,
  }
end

action :remove do
  raise 'later'
end
