#
# Cookbook Name:: monitor
# Recipe:: rabbitmq
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

sensu_gem "carrot-top"
sensu_gem "rest-client"

monitor_check 'rabbitmq-process' do
  file '/rabbitmq/rabbitmq-alive.rb'
  command '--username :::rabbitmq.user::: --password :::rabbitmq.password::: --vhost :::rabbitmq.vhost:::'
  handlers ['default']
  subscribers ['rabbitmq', 'sensu'] # because sensu installs it's own redis, not through a redis role. The master should have the role 'sensu'
  interval 30
end

monitor_check 'rabbitmq-overview-metrics' do
  file '/rabbitmq/rabbitmq-overview-metrics.rb'
  command '--user :::rabbitmq.user::: --password :::rabbitmq.password::: --scheme kwarter.:::name:::.rabbitmq'
  type 'metric'
  handlers ['metrics']
  subscribers ['rabbitmq', 'sensu'] # because sensu installs it's own redis, not through a redis role. The master should have the role 'sensu'
  interval 30
end

if node['monitor']['plugins']['rabbitmq']['monitored_queues']
  monitor_check 'rabbitmq-queue-metrics' do
    file '/rabbitmq/rabbitmq-queue-metrics.rb'
    command "--user :::rabbitmq.user::: --password :::rabbitmq.password::: --filter '#{node['monitor']['plugins']['rabbitmq']['monitored_queues']}' --scheme kwarter.:::name:::.rabbitmq.queues"
    type 'metric'
    handlers ['metrics']
    subscribers ['rabbitmq', 'sensu'] # because sensu installs it's own redis, not through a redis role. The master should have the role 'sensu'
    interval 30
  end
end
