#!/usr/bin/env ruby
#
# Couchbase check
# ===
#
# Copyright 2013 Kwarter, Inc.
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

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'net/http'

class CheckCouchbase < Sensu::Plugin::Check::CLI

  option :user,
         :short       => '-u',
         :long        => '--user USER',
         :default     => 'Administrator',
         :description => "Admin user"
  option :password,
         :short       => '-p',
         :long        => '--password PASSWORD',
         :description => "Admin Password"
  option :host,
         :short       => '-w',
         :long        => '--host host',
         :default     => 'localhost',
         :description => "The host"
  option :port,
         :short       => '-p',
         :long        => '--port port',
         :default     => 8091,
         :proc        => proc { |a| a.to_i },
         :description => "The port"
  option :timeout,
         :short       => '-t',
         :short       => '--timeout TIMEOUT',
         :default     => 3,
         :proc        => proc { |a| a.to_i },
         :description => "Timeout"

  # only get aliveness for now, in the future alert on mem quota, stuff like that

  def run
    begin
      timeout(config[:timeout]) do
        http = Net::HTTP.new(config[:host], config[:port])
        req  = Net::HTTP::Get.new('/pools/nodes/')
        req.basic_auth config[:user], config[:password]
        res = http.request(req)
        case res.code
          when /^2/
            ok "Can get node status"
          else
            critical res.code
        end
      end
    rescue Timeout::Error
      critical "Connection timed out"
    rescue => e
      critical "Connection error: #{e.message}"
    end
  end

end
