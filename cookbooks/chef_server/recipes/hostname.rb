
hostsfile_entry node['chef_server']['chef_server_ip'] do
    hostname node['chef_server']['chef_server_fqdn'] 
    action :create
end

hostsfile_entry node['chef_server']['chef_server_ip'] do
    hostname node['chef_server']['chef_server_host']
    action :append 
end

# execute 'set host name' do
#     command "hostnamectl set-hostname #{node['chef_server']['chef_server_host']}"
#     action :run
# end