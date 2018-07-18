
remote_file '/tmp/automate-1.8.85-1.el7.x86_64.rpm' do
    source 'https://packages.chef.io/files/stable/automate/1.8.85/el/7/automate-1.8.85-1.el7.x86_64.rpm'
end

package 'install chef automate' do
    source '/tmp/automate-1.8.85-1.el7.x86_64.rpm'
    action :install
end

cookbook_file '/home/abl/delivery.license' do
    source 'delivery.license'
end

bash 'configure sysctl' do
    cwd '/tmp'
    user 'root'
    code <<-EOH
        sysctl vm.swappiness=10
        sysctl -w vm.max_map_count=256000
        sysctl -w vm.dirty_expire_centisecs=30000
        sysctl -w net.ipv4.ip_local_port_range='35000 65000'
        EOH
    not_if 'sysctl vm.swappiness | grep 10' 
end

bash 'configure kernel' do
    cwd '/tmp'
    user 'root'
    code <<-EOH
        echo 'never' | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
        echo 'never' | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
        EOH
    not_if 'cat /sys/kernel/mm/transparent_hugepage/enabled | grep never'
    not_if 'cat /sys/kernel/mm/transparent_hugepage/defrag | grep never'
end

bash 'configure chef automate' do
    cwd '/tmp'
    user 'abl'
    code <<-EOH
        sudo automate-ctl setup --license /home/abl/delivery.license --server-url https://#{node['chef_automate']['chef_server_fqdn']}/organizations/acuityautomate --fqdn #{node['chef_automate']['chef_automate_fqdn']} --enterprise acuitybrands_mate --configure --no-build-node
        EOH
    not_if 'automate-ctl list-enterprises | grep acuitybrands_mate'
end

bash 'create automate user' do
    cwd '/tmp'
    code <<-EOH
        sudo automate-ctl create-user acuitybrands_mate dxi02 --password @password123 --roles reviewer,committer,admin,shipper,observer
        EOH
    not_if 'automate-ctl list-users acuitybrands_mate | grep dxi02'
end
    

bash 'configure data_collector' do
    cwd '/tmp'
    code <<-EOH
        echo "data_collector['token'] = 'chefsecuretoken'" >> /etc/delivery/delivery.rb
        automate-ctl reconfigure
        EOH
    not_if 'cat /etc/delivery/delivery.rb | grep chefsecuretoken'
end

