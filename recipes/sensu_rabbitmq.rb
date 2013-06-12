rabbitmq_user node[:sensu][:rabbitmq][:user] do
  user_tag 'monitoring'
  action :set_user_tags
end

require 'cgi'

node.set[:monitor][:additional_client_attributes][:rabbitmq] = {
    :user     => node[:sensu][:rabbitmq][:user],
    :password => node[:sensu][:rabbitmq][:password],
    :vhost    => ::CGI.escape(node[:sensu][:rabbitmq][:vhost])
}

include_recipe 'monitor::rabbitmq'
