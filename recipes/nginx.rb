#
# Cookbook Name:: monitor
# Recipe:: nginx
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

sensu_check 'nginx-process' do
  #file '/processes/check-procs.rb'
  command "check-procs.rb -f #{node[:nginx][:pid]}"
  handlers ['default']
  subscribers ['nginx']
  interval 30
end

sensu_check 'nginx-metrics' do
  #file '/nginx/nginx-metrics.rb'
  command 'nginx-metrics.rb --url http://localhost:8090/nginx_status --scheme kwarter.:::name:::.nginx'
  type 'metric'
  handlers ['metrics']
  subscribers ['nginx']
  interval 30
end

pidfile = "replace_me_with_pidfile"
if node[:nginx]
  pidfile = node[:nginx][:pid]
end

sensu_check 'nginx-limits' do
  #file '/processes/check-limits.rb'
  command "check-limits.rb -p %s -f -W 10000 -C 1025" % pidfile
  handlers ['default']
  subscribers ['nginx']
  interval 30
end
