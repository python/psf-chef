package 'postgresql-client'

postgres = data_bag_item('secrets', 'postgres')
postgres.delete('id')

file '/etc/rsnapshot_postgres_passwords' do
  owner 'root'
  group 'root'
  mode '0600'
  content postgres.map{|name, data| "*:*:*:#{data['user']}:#{data['password']}\n"}.join('')
end

postgres.each do |name, data|
  rsnapshot_script "postgres-#{name}" do
    command "/usr/bin/env PGPASSFILE=/etc/rsnapshot_postgres_passwords pg_dump -h #{data['hostname']} -U #{data['user']} -f backup.sql #{data['database']}"
  end
end
