#!/usr/bin/env ruby
#
# check-numa.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-plugin/check/cli'
require 'facter'

class CheckNuma < Sensu::Plugin::Check::CLI
  option :ignore_virtual,
         :description => "Ignore NUMA on virtualized hardware",
         :long => "--ignore-virtual",
         :boolean => true,
         :default => false

  option :warn,
         :description => "Warn instead of throwing a critical failure",
         :short => "-w",
         :long => "--warn",
         :boolean => true,
         :default => false

  def initialize()
    super

    @cpuinfo = get_cpuinfo()
  end

  def get_cpuinfo()
    cpuinfo = {}

    data = %x[cat /proc/cpuinfo]
    cpuinfo['model'] = data[/^model\s*:\s*(\d+)/, 1].to_i
    cpuinfo['physicalprocessorcount'] = data.scan(/^physical id\s*:/).size

    cpuinfo
  end

  def is_supported?()
    # a few CPUs that made history
    case @cpuinfo['model']
      when 13 # Dothan
        return false
      when 3, 4 # Prescott
        return false
      when 6 # Presler
        return false
      when 22, 15 # Merom
        return false
      when 29, 23 # Penryn
        return false
      else # >= Nehalem
        return true
    end
  end

  def numa_nodes_count()
    %x[find /sys/devices/system/node/* -maxdepth 0 -type d -name 'node*'].split("\n").count
  end

  def run
    if Facter.value('is_virtual') and config[:ignore_virtual]
      ok("NUMA is not supported (Virtual hardware)")
    elsif is_supported?()
      if @cpuinfo['physicalprocessorcount'] > 1
        if numa_nodes_count() > 1 and
          ok("NUMA is enabled")
        else
          if config[:warn]
            warning("NUMA is disabled")
          else
            critical("NUMA is disabled")
          end
        end
      else
        ok("NUMA not monitored - Only 1 physical processor detected")
      end
    else
      ok("NUMA is not supported")
    end
  end
end
