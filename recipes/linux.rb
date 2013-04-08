
monitor_check 'disk_usage' do
  file '/system/check-disk.rb'
  command '-w 70 -c 80 -x nfs,tmpfs,fuse -i /'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
  notification 'Disk usage is too high.'
end

monitor_check 'memory' do
  file '/system/check-mem.rb'
  command '-w 30 -c 25'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
  notification 'Memory usage is too high.'
end

monitor_check 'swap' do
  file '/system/check-swap.sh -w '
  command '--swap -w 60 -c 50'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
  notification 'Swap usage is too high.'
end

monitor_check 'load' do
  file '/etc/sensu/plugins/system/check-load.rb'
  command '-w 10,15,25 -c 15,20,30'
  handlers ['default']
  standalone true
  interval 30
  subscribers ['base']
  notification 'Load is too high.'
end
