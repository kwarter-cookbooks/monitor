#
# Cookbook Name:: monitor
# Recipe:: redis
#
# Copyright 2013, Sean Porter Consulting
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

sensu_gem "redis"

monitor_check 'redis-process' do
  file '/processes/check-procs.rb'
  command '-p redis-server -C 1 -c 2 -w 2'
  handlers ['default']
  subscribers ['redis', 'sensu'] # because sensu installs it's own redis, not through a redis role. The master should have the role 'sensu'
  interval 30
end

monitor_check 'redis-metrics' do
  file '/redis/redis-graphite.rb'
  command '--scheme kwarter.:::name:::.redis'
  type 'metric'
  handlers ['metrics']
  subscribers ['redis', 'sensu'] # because sensu installs it's own redis, not through a redis role. The master should have the role 'sensu'
  interval 30
end
