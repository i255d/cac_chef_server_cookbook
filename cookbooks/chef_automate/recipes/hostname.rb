hostsfile_entry node['chef_automate']['chef_automate_ip'] do
    hostname node['chef_automate']['chef_automate_fqdn']
    action :create
end

hostsfile_entry node['chef_automate']['chef_automate_ip'] do
    hostname node['chef_automate']['chef_automate_host']
    action :append 
end

execute 'set host name' do
    command "hostnamectl set-hostname #{node['chef_automate']['chef_automate_host']}"
    action :run
end