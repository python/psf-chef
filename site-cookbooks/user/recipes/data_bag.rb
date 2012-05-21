#
# Cookbook Name:: user
# Recipe:: data_bag
#
# Copyright 2011, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'sudo'

bag   = node['user']['data_bag']

admin_groups = []

search(bag, "*:*") do |u|
  username = u['username'] || u['id']

  user_account username do
    %w{comment uid gid home shell password system_user manage_home create_group
        ssh_keys ssh_keygen}.each do |attr|
      send(attr, u[attr]) if u[attr]
    end

    # If you don't match the roles for this node, make sure you don't exist
    if u['roles'].is_a?(Array) && !u['roles'].any?{|role| node['roles'].include?(role)}
      action :remove
    else
      action u['action'].to_sym if u['action']
    end
  end

  # If :sudo is an array, check roles, otherwise if it is true just apply sudo globally
  if u['sudo'].is_a?(Array)
    admin_group << username if u['sudo'].any?{|role| node['roles'].include?(role)}
  elsif u['sudo'].is_a?(Hash)
    cmds = []
    u['sudo'].each_pair do |role, cmd|
      cmds << cmd if node['roles'].include?(role)
    end
    if cmds.present?
      sudo username do
        user username
        commands cmds
        nopasswd true
      end
    end
  elsif u['sudo']
    admin_group << username
  end

end

if admin_groups.present?
  group "admin" do
    action [:create, :manage]
    members admin_group
  end
end

sudo "admin" do
  group "admin"
  nopasswd true
end
