# Cookbook Name:: monitor
# Recipe:: couchbase
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

monitor_check 'couchbase-process' do
  file '/couchbase/check-couchbase.rb'
  command '--password :::couchbase.password:::'
  handlers ['default']
  subscribers ['couchbase']
  interval 30
end

monitor_check 'couchbase-limits' do
  file '/processes/check-limits.rb'
  command '-p /opt/couchbase/var/lib/couchbase/couchbase-server.pid -f -W 10000 -C 1025'
  handlers ['default']
  subscribers ['couchbase']
  interval 30
end

monitor_check 'couchbase-metrics' do
  file '/couchbase/couchbase_sensu.py'
  command ""
  type 'metric'
  handlers ['metrics']
  subscribers ['couchbase']
  interval 30
end
