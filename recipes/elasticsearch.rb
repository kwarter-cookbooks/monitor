# Cookbook Name:: monitor
# Recipe:: elasticsearch
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

sensu_gem "rest-client"

monitor_check 'elasticsearch-process' do
  file '/processes/check-procs.rb'
  command "-p 'org.elasticsearch.bootstrap.ElasticSearch' -C 1"
  handlers ['default']
  subscribers ['elasticsearch']
  standalone true
  interval 30
end

monitor_check 'elasticsearch-metrics' do
  file '/elasticsearch/es-node-graphite.rb'
  command '--scheme kwarter.:::name:::.elasticsearch'
  type 'metric'
  handlers ['metrics']
  subscribers ['elasticsearch']
  standalone true
  interval 30
end
