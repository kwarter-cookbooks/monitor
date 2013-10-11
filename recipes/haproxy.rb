#
# Cookbook Name:: monitor
# Recipe:: cassandra
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

sensu_gem "haproxy"

monitor_check 'haproxy-check' do
  file '/haproxy/check-haproxy.rb'
  command '-s servers-http'
  handlers ['default']
  subscribers ['haproxy']
  interval 30
end

monitor_check 'haproxy-metrics' do
  file '/haproxy/haproxy-metrics.rb'
  command '--connect /var/run/haproxy.sock --scheme kwarter.:::name:::.haproxy'
  type 'metric'
  handlers ['metrics']
  subscribers ['haproxy']
  interval 30
end
