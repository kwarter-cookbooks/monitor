action :create do

  target_file = ::File.join(node.sensu.plugins_directory, new_resource.file)

  directory ::File.dirname(target_file) do
    mode 0755
  end

  cookbook_file target_file do
    source ::File.join('plugins', new_resource.file)
    mode 0755
  end

  sensu_check new_resource.name do
    type new_resource.type
    command "#{::File.join(node.sensu.plugins_directory, new_resource.file)} #{new_resource.command}"
    subscribers new_resource.subscribers
    standalone new_resource.standalone
    interval new_resource.interval
    handlers new_resource.handlers
    additional new_resource.additional
  end
end

action :delete do
  sensu_check new_resource.name do
    action :delete
  end
end
