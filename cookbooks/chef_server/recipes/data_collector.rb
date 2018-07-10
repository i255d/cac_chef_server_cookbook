bash 'automate data_collector' do
    cwd '/tmp'
    code <<-EOH
        chef-server-ctl set-secret data_collector token 'chefsecuretoken'
        chef-server-ctl restart nginx
        chef-server-ctl restart opscode-erchef
    EOH
    not_if 'chef-server-ctl show-secret data_collector token | grep -w chefsecuretoken'
end

bash 'append chef-server.rb' do
    cwd '/tmp'
    code <<-EOH
        echo "data_collector['root_url'] = 'https://#{node['chef_server']['chef_automate_fqdn']}/data-collector/v0/'" >> /etc/opscode/chef-server.rb
        echo "profiles['root_url'] = 'https://#{node['chef_server']['chef_automate_fqdn']}'" >> /etc/opscode/chef-server.rb
        echo "opscode_erchef['max_request_size'] = 3000000" >> /etc/opscode/chef-server.rb
        chef-server-ctl reconfigure
    EOH
    not_if "cat /etc/opscode/chef-server.rb | grep -w 'https://#{node['chef_server']['chef_automate_fqdn']}/data-collector/v0/'"
    not_if 'cat /etc/opscode/chef-server.rb | grep -w profiles'
    not_if 'cat /etc/opscode/chef-server.rb | grep -w max_request_size'
end

