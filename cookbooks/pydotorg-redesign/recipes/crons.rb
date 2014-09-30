current_env = node['pydotorg-redesign']['env']

cron_d 'import-blog-feeds' do
  command "/srv/redesign.python.org/shared/env/bin/python /srv/redesign.python.org/current/manage.py update_blogs --settings pydotorg.settings.#{current_env}"
  user 'www-data'
  hour 0
end

cron_d 'import-ics-events' do
  command "/srv/redesign.python.org/shared/env/bin/python /srv/redesign.python.org/current/manage.py import_ics_calendars --settings pydotorg.settings.#{current_env}"
  user 'www-data'
  minute 17
end

cron_d 'update-es-index' do
  command "/srv/redesign.python.org/shared/env/bin/python /srv/redesign.python.org/current/manage.py rebuild_index --settings pydotorg.settings.#{current_env} --noinput"
  user 'www-data'
  minute 0
  hour 2
end

cron_d 'update-peps' do
  command "make -C /srv/peps update all && /srv/redesign.python.org/shared/env/bin/python /srv/redesign.python.org/current/manage.py generate_pep_pages --settings pydotorg.settings.#{current_env}"
  user 'www-data'
  minute 10
end
