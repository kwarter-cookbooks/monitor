sensu_gem 'hipchat'

cookbook_file ::File.join(node['sensu']['directory'], 'handlers', 'hipchat.rb') do
  source 'handlers/notification/hipchat.rb'
  mode 0755
end

sensu_handler 'hipchat' do
  type 'pipe'
  command 'hipchat.rb'
end

sensu_snippet 'hipchat' do
  content(
      :apikey => node['monitor']['hipchat']['apikey'],
      :room   => node['monitor']['hipchat']['room']
  )
end
