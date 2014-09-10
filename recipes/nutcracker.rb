#
# Cookbook Name:: monitor
# Recipe:: nutcracker
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

sensu_check 'nutcracker-process' do
  #file '/processes/check-procs.rb'
  command "check-procs.rb -p 'nutcracker.*nutcracker.conf' -C 1"
  handlers ['default']
  subscribers ['app']
  interval 30
end

sensu_check 'nutcracker-metrics' do
  #file '/nutcracker/nutcracker-metrics.rb'
  command 'nutcracker-metrics.rb --scheme kwarter.:::name:::.nutcracker'
  type 'metric'
  handlers ['metrics']
  subscribers ['app']
  interval 30
end

sensu_check 'nutcracker-limits' do
  #file '/processes/check-limits.rb'
  command 'check-limits.rb -p /var/run/nutcracker/nutcracker.pid -f -W 10000 -C 1025'
  handlers ['default']
  subscribers ['app']
  interval 30
end
