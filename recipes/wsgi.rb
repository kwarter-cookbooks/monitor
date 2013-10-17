#
# Cookbook Name:: monitor
# Recipe:: wsgi
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

monitor_check 'wsgi-limits' do
  file '/processes/check-limits.rb'
  command '-p /srv/www/app.kwarter.com/shared/app.pid -f -W 10000 -C 1025'
  handlers ['default']
  subscribers ['app-api']
  interval 30
end
