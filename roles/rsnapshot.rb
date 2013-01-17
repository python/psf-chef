name "rsnapshot"
description "RSnapshot backup server"
# Owner: Noah Kantrowitz <noah@coderanger.net>

run_list 'recipe[rsnapshot::server]', 'recipe[psf-rsnapshot::postgres]'
