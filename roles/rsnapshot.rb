name "rsnapshot"
description "RSnapshot backup server"
# Owner: Noah Kantrowitz <noah@coderanger.net>

run_list 'recipe[psf-postgresql::92]','recipe[rsnapshot::server]', 'recipe[psf-rsnapshot::postgres]'

override_attributes({
  rsnapshot: {
    server: {
      retain: {
        hourly: {
          count: 4,
          hour: '*/6',
        },
        daily: {
          count: 7,
        }
      },
    },
  },
})
