#!/usr/bin/env ruby
#
# System CPU plugin
# ===
#
# Uses iostat to get CPU thresholds, includes Steal
#
# Copyright 2013 Kwarter, Inc <platforms@kwarter.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'socket'

class CPU < Sensu::Plugin::Check::CLI

  option :warning,
         :description => "Warning level in %",
         :short       => "-w PERCENT",
         :long        => "--warning PERCENT",
         :default     => 50

  option :critical,
         :description => "Critical level in %",
         :short       => "-c PERCENT",
         :long        => "--critical PERCENT",
         :default     => 75

  option :steal_warning,
         :description => "Steal warning level in %",
         :short       => "-sw PERCENT",
         :long        => "--steal_warning PERCENT",
         :default     => 15

  option :steal_critical,
         :description => "Steal critical level in %",
         :short       => "-sc PERCENT",
         :long        => "--steal_critical PERCENT",
         :default     => 30

  option :interval,
         :description => "Check interval",
         :short       => "--i INTERVAL",
         :long        => "--interval INTERVAL",
         :default     => 1

  option :num_reports,
         :description => "Num reports",
         :short       => "--n NUM_REPORTS",
         :long        => "--reports NUM_REPORTS",
         :default     => 2

  def run
    results = `iostat -c #{config[:interval]} #{config[:num_reports]} | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d'`

    results = results.split(/\n/).select do |line|
      line.start_with?(';')
    end

    all = {
        :user   => 0,
        :nice   => 0,
        :system => 0,
        :iowait => 0,
        :steal  => 0,
        :idle   => 0,
    }
    results.each do |line|
      result       = line.split(';')
      all[:user]   += result[1].to_f
      all[:nice]   += result[2].to_f
      all[:system] += result[3].to_f
      all[:iowait] += result[4].to_f
      all[:steal]  += result[5].to_f
      all[:idle]   += result[6].to_f
    end

    total_cpu = (all[:user] + all[:system] + all[:iowait]) / config[:num_reports]
    critical("CPU is too high: #{total_cpu} (user: #{all[:user] / config[:num_reports]}, system: #{all[:system] / config[:num_reports]}, iowait: #{all[:iowait] / config[:num_reports]})") if total_cpu > config[:critical]
    warning("CPU is too high: #{total_cpu} (user: #{all[:user] / config[:num_reports]}, system: #{all[:system] / config[:num_reports]}, iowait: #{all[:iowait] / config[:num_reports]})") if total_cpu > config[:warning]
    critical("Steal CPU is too high: #{all[:steal] / config[:num_reports]}") if all[:steal] / config[:num_reports] > config[:steal_critical]
    warning("Steal CPU is too high: #{all[:steal] / config[:num_reports]}") if all[:steal] / config[:num_reports] > config[:steal_warning]
    ok
  end

end
