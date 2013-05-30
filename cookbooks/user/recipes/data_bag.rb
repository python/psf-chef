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
lockdown = node['user']['lockdown']

admin_group = []

search(bag, "*:*") do |u|
  username = u['username'] || u['id']

  # Figure out if we should force-remove this user
  remove_user = u['roles'].is_a?(Array) && !u['roles'].any?{|role| node['roles'].include?(role)}

  # If :sudo is an array, check roles, otherwise if it is true just apply sudo globally
  if u['sudo'].is_a?(Array) && u['sudo'].any?{|role| node['roles'].include?(role)}
    admin_group << username
  elsif u['sudo'].is_a?(Hash) && u['sudo'].any?{|role, cmd| node['roles'].include?(role)}
    cmds = []
    u['sudo'].each_pair do |role, cmd|
      cmds << cmd if node['roles'].include?(role)
    end
    if !cmds.empty?
      sudo username do
        user username
        commands cmds
        nopasswd true
      end
    end
  elsif u['sudo'] == true
    admin_group << username
  elsif lockdown
    # When under lockdown mode, any user without sudo isn't allowed in at all
    remove_user = true
  end

  user_account username do
    %w{comment uid gid home shell password system_user manage_home create_group
        ssh_keys ssh_keygen}.each do |attr|
      send(attr, u[attr]) if u[attr]
    end

    # If you don't match the roles for this node, make sure you don't exist
    if remove_user
      action :remove
    else
      action u['action'].to_sym if u['action']
    end
  end
end

group "admin" do
  action [:create, :manage]
  members admin_group
end

sudo "admin" do
  group "admin"
  nopasswd true
  commands ["ALL"]
end
