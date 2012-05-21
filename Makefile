delete:
	knife ec2 server list | tail +2 | grep running | awk '{print $$1;}' | xargs -n 1 knife ec2 server delete -y
	yes | knife node bulk_delete 'i-.*'

ip:
	@knife ec2 server list | tail +2 | grep running | awk '{print $$2;}'

ssh:
	ssh -o StrictHostKeyChecking=no "ubuntu@$$(make ip)"

trace:
	@ssh -o StrictHostKeyChecking=no "ubuntu@$$(make ip)" cat /var/chef/cache/chef-stacktrace.out
	@echo

