#!/usr/bin/env ruby
#
# Notcracker metrics
# ===
#
# Copyright 2013 Kwarter, Inc,
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

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'socket'
require 'timeout'


class NutcrackerMetrics < Sensu::Plugin::Metric::CLI::Graphite

  option :host,
         :description => 'Nutcracker host',
         :long        => '--host HOST',
         :default     => 'localhost'

  option :port,
         :description => 'Nutcracker stats port',
         :long        => '--port PORT',
         :proc        => proc { |p| p.to_i },
         :default     => 22222

  option :scheme,
         :description => 'Metric naming scheme',
         :long        => '--scheme SCHEME',
         :default     => "#{Socket.gethostname}.nutcracker"

  def get_nutcracker_info
    data = nil
    begin
      Timeout::timeout(30) do
        TCPSocket.open(config[:host], config[:port]) do |socket|
          data = socket.read
        end
      end
    rescue Timeout::Error
      warning "timed out connecting to memcached on port #{config[:port]}"
    rescue
      critical "Can't connect to port #{config[:port]}"
    end
    JSON.parse(data)
  end

  def process_backend(prefix, stats)
    stats.each do |key, value|
      if value.is_a?(Hash)
        process_backend("#{prefix}.#{key}", value)
      else
        output "#{config[:scheme]}.#{prefix}.#{key}", value, @now
      end
    end
  end

  def run
    data = get_nutcracker_info
    if data.nil?
      return
    end
    @now   = data['timestamp']
    filter = ['service', 'source', 'version', 'uptime', 'timestamp']
    data.reject { |key, value| filter.include?(key) }.each do |backend, stats|
      process_backend(backend, stats)
    end
    ok
  end

end
