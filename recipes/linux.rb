sensu_gem 'ohai'

monitor_check 'disk-usage' do
  file '/system/check-disk.rb'
  command '-w 70 -c 80 -x nfs,tmpfs,fuse'
  handlers ['default']
  interval 30
  subscribers ['base']
  additional({
                 :occurrences => 2
             })
end

monitor_check 'memory' do
  file '/system/check-mem.rb'
  command '-w 30 -c 25'
  handlers ['default']
  interval 30
  subscribers ['base']
  additional({
                 :occurrences => 2
             })
end

monitor_check 'swap' do
  file '/system/check-mem.rb'
  command '--swap -w 60 -c 50'
  handlers ['default']
  interval 30
  subscribers ['base']
  additional({
                 :occurrences => 2
             })
end

monitor_check 'load' do
  file '/system/check-load.rb'
  command '-w 10,15,25 -c 15,20,30'
  handlers ['default']
  interval 30
  subscribers ['base']
  additional({
                 :occurrences => 2
             })
end

# this seems way too sensitive, rely on load even if it seems weird. We also have newrelic
#monitor_check 'cpu' do
#  file '/system/cpu.rb'
#  command ''
#  handlers ['default']
#  standalone true
#  interval 30
#  subscribers ['base']
#  additional({
#                 :occurrences => 2
#             })
#end

# This is a 2nd attempt to add a proper cpu check but it failed. 
#monitor_check 'cpu' do
#  file '/system/check-cpu.rb'
#  command '-w 80 -c 95'
#  handlers ['default']
#  interval 30
#  subscribers ['base']
#  additional({
#                 :occurrences => 3
#             })
#end

%w(cpu-metrics disk-capacity-metrics disk-metrics interface-metrics load-metrics memory-metrics vmstat-metrics).each do |metric|
  monitor_check metric do
    file "/system/#{metric}.rb"
    type 'metric'
    command '--scheme kwarter.:::name:::'
    handlers ['metrics']
    interval 30
    subscribers ['base']
    additional({
                   :occurrences => 2
               })
  end
end
