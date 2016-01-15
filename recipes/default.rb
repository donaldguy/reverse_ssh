reverse_ssh_tunnel node['reverse_ssh']['target_name'] do
  host node['reverse_ssh']['server_url']
  port node['reverse_ssh']['target_port']

  local_user node['reverse_ssh']['local_user']
  remote_user node['reverse_ssh']['remote_user']
end
