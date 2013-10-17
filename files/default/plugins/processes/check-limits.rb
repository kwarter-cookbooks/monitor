#!/usr/bin/env ruby
#
# Check File descriptors
# ===
#
# Check file descriptor limit for a given process by reading /proc/pid/limits
# For now the process has to have a PID file
#
# Examples:
#
#   check-fd -p path/to/pidfile -w 70000 -W 2048 -c 100000 -C 1024
#
#
# Copyright 2013 Kwarter, Inc <platforms@kwarter.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'

class CheckLimit < Sensu::Plugin::Check::CLI

  class << self
    attr_reader :OK
    attr_reader :WARN
    attr_reader :CRIT
  end


  @OK   = 0
  @WARN = 1
  @CRIT = 2

  def self.read_pid(path)
    begin
      File.read(path).chomp.to_i
    rescue
      self.new.unknown "Could not read pid file #{path}"
    end
  end

  option :warn_over,
         :short   => '-w N',
         :proc    => proc { |a| a.to_i },
         :default => 1000000

  option :crit_over,
         :short   => '-c N',
         :proc    => proc { |a| a.to_i },
         :default => 1000000

  option :warn_under,
         :short   => '-W N',
         :proc    => proc { |a| a.to_i },
         :default => 0

  option :crit_under,
         :short   => '-C N',
         :proc    => proc { |a| a.to_i },
         :default => 0

  option :file_pid,
         :short => '-p PATH',
         :proc  => proc { |a| read_pid(a) }

  option :name,
         :short => '-n NAME'

  option :hard,
         :short       => '-h',
         :description => "Check hard limits",
         :default     => true

  option :soft,
         :short       => '-s',
         :description => "Check soft limits",
         :default     => true

  option :fds,
         :short       => '-f',
         :description => "Check file descriptor"

  option :max_procs,
         :short       => '-o',
         :description => "Check max processes"

  option :file_pid, :short => '-p PATH', :proc => proc { |a| read_pid(a) }

  def check_status(value)
    status = CheckLimit.OK
    msg    = nil
    if value != 'unlimited'
      value = Integer(value)
      if value < config[:crit_under]
        status = CheckLimit.CRIT
        msg    = '(UNDER)'
      elsif value > config[:crit_over]
        status = CheckLimit.CRIT
        msg    = '(OVER)'
      elsif value < config[:warn_under]
      elsif value > config[:warn_over]
        msg    = '(OVER)'
        status = CheckLimit.WARN
      end
    end
    return status, msg
  end

  def check_metric(data, metric)
    status = CheckLimit.OK
    msg    = "#{metric}: "
    msg_parts = []
    data.each do |line|
      as_list = line.split(/\s{2,}/)
      next unless as_list[0] == metric

      [:soft, :hard].each do |limit|
        if config[limit]
          value      = as_list[1]
          msg_part    = "#{limit}=#{value}"
          tmp_status, tmp_msg = check_status(value)
          if tmp_msg
            msg_part += " #{tmp_msg}"
          end
          msg_parts << msg_part
          if tmp_status > status
            status = tmp_status
          end
        end
      end
    end
    return status, msg + msg_parts.join('/')
  end

  def run

    max_status = 0
    messages   = ["#{config[:name]}"]

    metrics = []
    if config[:fds]
      metrics << 'Max open files'
    end
    if config[:max_procs]
      metrics << 'Max processes'
    end

    limit_file = File.read("/proc/#{config[:file_pid]}/limits/")
    metrics.each do |metric|
      status, msg = check_metric(limit_file, metric)
      if status > max_status
        max_status = status
      end
      messages << msg
    end

    msg = messages.join('; ')
    if max_status == CheckLimit.WARN
      warning msg
    elsif max_status == CheckLimit.CRIT
      critical msg
    else
      ok msg
    end

  end

end
