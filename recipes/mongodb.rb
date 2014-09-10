#
# Cookbook Name:: monitor
# Recipe:: mongo
#
# Copyright 2013, Kwarter, Inc.
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

sensu_check 'mongodb-process' do
  #file '/processes/check-procs.rb'
  command "check-procs.rb -p 'mongod --config' -C 1"
  handlers ['default']
  subscribers ['mongodb-events']
  interval 30
end

# this is not adapted for mongos or shard but we don't use them
pidfile = "replace_me_with_pidfile"
if node[:mongodb][:pidpath]
  pidfile = File.join(node[:mongodb][:pidpath], "mongodb.pid")
end

sensu_check 'mongodb-limits' do
  #file '/processes/check-limits.rb'
  command "check-limits.rb -p %s -f -W 10000 -C 1025" % pidfile
  handlers ['default']
  subscribers ['mongodb-events']
  interval 30
end
