#!/usr/bin/env ruby
#
# Check RabbitMQ Consumer Count
# ===
#
# Copyright 2013 Tony Chong <tony.chong@kwarter.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'socket'
require 'carrot-top'

class CheckRabbitMQConsumers < Sensu::Plugin::Check::CLI

  option :host,
    :description => "RabbitMQ management API host",
    :long => "--host HOST",
    :default => "localhost"

  option :port,
    :description => "RabbitMQ management API port",
    :long => "--port PORT",
    :proc => proc {|p| p.to_i},
    :default => 55672

  option :user,
    :description => "RabbitMQ management API user",
    :long => "--user USER",
    :default => "guest"

  option :password,
    :description => "RabbitMQ management API password",
    :long => "--password PASSWORD",
    :default => "guest"

  option :warn,
    :short => '-w NUM_MESSAGES',
    :long => '--warn NUM_MESSAGES',
    :description => 'WARNING consumer count threshold',
    :default => 50

  option :critical,
    :short => '-c NUM_MESSAGES',
    :long => '--critical NUM_MESSAGES',
    :description => 'CRITICAL consumer count threshold',
    :default => 1



  def get_rabbitmq_info
    begin
      rabbitmq_info = CarrotTop.new(
        :host => config[:host],
        :port => config[:port],
        :user => config[:user],
        :password => config[:password]
      )
    rescue
      warning "could not get rabbitmq info"
    end
    rabbitmq_info
  end

  def run
    rabbitmq = get_rabbitmq_info
    overview = rabbitmq.overview
    consumers = overview['object_totals']['consumers']
    message "#{consumers}"
    critical if consumers < config[:critical].to_i
    warning if consumers < config[:warn].to_i
    ok
  end

end