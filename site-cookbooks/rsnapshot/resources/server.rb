default_action :install
actions :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :dir, :kind_of => String, :default => '/etc'

attribute :config_version, :kind_of => String, :default => '1.2'
attribute :snapshot_root, :kind_of => String, :default => '/var/cache/rsnapshot'
attribute :no_create_root, :kind_of => [TrueClass, FalseClass], :default => false

attribute :cmd_cp, :kind_of => [String, NilClass], :default => '/bin/cp'
attribute :cmd_rm, :kind_of => [String, NilClass], :default => '/bin/rm'
attribute :cmd_rsync, :kind_of => [String, NilClass], :default => '/usr/bin/rsync'
attribute :cmd_ssh, :kind_of => [String, NilClass], :default => '/usr/bin/ssh'
attribute :cmd_logger, :kind_of => [String, NilClass], :default => '/usr/bin/logger'
attribute :cmd_du, :kind_of => [String, NilClass], :default => '/usr/bin/du'
attribute :cmd_rsnapshot_diff, :kind_of => [String, NilClass], :default => '/usr/bin/rsnapshot-diff'
attribute :cmd_preexec, :kind_of => [String, NilClass], :default => nil
attribute :cmd_postexec, :kind_of => [String, NilClass], :default => nil

attribute :linux_lvm_cmd_lvcreate, :kind_of => [String, NilClass], :default => nil
attribute :linux_lvm_cmd_lvremove, :kind_of => [String, NilClass], :default => nil
attribute :linux_lvm_cmd_mount, :kind_of => [String, NilClass], :default => nil
attribute :linux_lvm_cmd_umount, :kind_of => [String, NilClass], :default => nil

attribute :_retain, :kind_of => Array, :default => []
def retain(name=nil, values=nil, &block)
  if name
    ret = RsnapshotRetain.new(name)
    if values
      values.each do |key, value|
        ret.send(key, value)
      end
    end
    ret.instance_eval(&block) if block
    self._retain << ret
  else
    self._retain
  end
end

attribute :verbose, :equal_to => [1, 2, 3, 4, 5], :default => 2
attribute :loglevel, :equal_to => [1, 2, 3, 4, 5], :default => 3
attribute :logfile, :kind_of => [String, NilClass], :default => nil
attribute :lockfile, :kind_of => String, :default => '/var/run/rsnapshot.pid'
attribute :stop_on_stale_lockfile, :kind_of => [TrueClass, FalseClass], :default => true
attribute :rsync_short_args, :kind_of => String, :default => '-a'
attribute :rsync_long_args, :kind_of => String, :default => '--delete --numeric-ids --relative --delete-excluded'
attribute :ssh_args, :kind_of => [String, NilClass], :default => nil
attribute :du_args, :kind_of => [String, NilClass], :default => '-csh'
attribute :one_fs, :kind_of => [TrueClass, FalseClass], :default => false
attribute :link_dest, :kind_of => [TrueClass, FalseClass], :default => false
attribute :sync_first, :kind_of => [TrueClass, FalseClass], :default => false
attribute :use_lazy_deletes, :kind_of => [TrueClass, FalseClass], :default => false
attribute :rsync_numtries, :kind_of => [Integer, NilClass], :default => nil
attribute :linux_lvm_snapshotsize, :kind_of => [String, NilClass], :default => nil
attribute :linux_lvm_snapshotname, :kind_of => [String, NilClass], :default => nil
attribute :linux_lvm_vgpath, :kind_of => [String, NilClass], :default => nil
attribute :linux_lvm_mountpath, :kind_of => [String, NilClass], :default => nil
