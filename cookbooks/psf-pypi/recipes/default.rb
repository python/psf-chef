
resources('rsnapshot_backup[/]').action(:nothing)

sysctl_param 'kernel.panic' do
  value 10
end
