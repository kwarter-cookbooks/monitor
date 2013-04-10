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
require 'sensu-plugin/metric/cli'
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
    result = `iostat -c #{config[:interval]} #{config[:num_reports]} | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d' | tail -1`.split(";")

    user   = result[1].to_f
    nice   = result[2].to_f
    system = result[3].to_f
    iowait = result[4].to_f
    steal  = result[5].to_f
    idle   = result[6].to_f

    total_cpu = user + system + iowait
    critical('CRITICAL: CPU is too high') if total_cpu > config[:critical]
    warning('WARNING: CPU is too high') if total_cpu > config[:warning]
    critical('CRITICAL: Steal CPU is too high') if steal > config[:steal_critical]
    warning('WARNING: Steal CPU is too high') if steal > config[:steal_warning]
    ok
  end

end
