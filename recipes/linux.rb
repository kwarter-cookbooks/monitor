sensu_gem 'ohai'

monitor_check 'disk-usage' do
  file '/system/check-disk.rb'
  command '-w 70 -c 80 -x nfs,tmpfs,fuse -i /'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
end

monitor_check 'memory' do
  file '/system/check-mem.rb'
  command '-w 30 -c 25'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
end

monitor_check 'swap' do
  file '/system/check-mem.rb'
  command '--swap -w 60 -c 50'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
end

monitor_check 'load' do
  file '/system/check-load.rb'
  command '-w 10,15,25 -c 15,20,30'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
end

monitor_check 'cpu' do
  file '/system/cpu.rb'
  command ''
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
end

%w(cpu-metrics disk-capacity-metrics disk-metrics interface-metrics load-metrics memory-metrics vmstat-metrics).each do |metric|
  monitor_check metric do
    file "/system/#{metric}.rb"
    type 'metric'
    command '--scheme kwarter.:::name:::'
    handlers ['metrics']
    standalone true
    interval 30
    subscribers ['base']
  end
end
