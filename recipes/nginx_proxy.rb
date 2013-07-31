include_recipe 'nginx'

if node['monitor']['nginx']['ssl']
  proxy = data_bag_item('sensu', 'proxy')
  ssl_record = proxy[node[:ec2][:placement_availability_zone][0...-1]]
  unless ssl_record
    # take a default one
    ssl_record = proxy.reject {|key, value| key == "id"}
    ssl_record = ssl_record[ssl_record.keys[0]]
  end

  if ssl_record
    directory File.join(node['nginx']['dir'], 'ssl') do
      owner 'root'
      group 'root'
      mode '0755'
    end

    %w(key cert).each do |item|
      file File.join(node['nginx']['dir'], 'ssl', "sensu.#{item}") do
        content ssl_record[item]
        mode 0644
      end
    end
  end
end

template File.join(node['nginx']['dir'], 'sites-available', 'sensu') do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables :ssl_key  => File.join(node['nginx']['dir'], 'ssl', 'sensu.key'),
            :ssl_cert => File.join(node['nginx']['dir'], 'ssl', 'sensu.cert')
  notifies :reload, resources(:service => 'nginx')
end

nginx_site 'sensu' do
  enable true
end
