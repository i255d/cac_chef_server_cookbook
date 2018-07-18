
remote_file '/tmp/chef-automate_linux_amd64.zip' do
    source 'https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'
end

bash 'unzipinstall_file' do
    cwd '/tmp'
    user 'root'
    code <<-EOH
        gunzip /tmp/chef-automate_linux_amd64.zip > chef-automate 
        mv /tmp/chef-automate /usr/bin/chef-automate 
        sudo chmod +x /usr/bin/chef-automate
        EOH
    not_if 'ls /usr/bin/chef-automate'
end


bash 'configure sysctl-max_map' do
    cwd '/tmp'
    user 'root'
    code <<-EOH
        'vm.max_map_count=262144' >> /etc/sysctl.conf
        sysctl -p
        EOH
    not_if 'grep vm.max_map_count=262144 /etc/sysctl.conf' 
end

bash 'configure sysctl-dirty_expire' do
    cwd '/tmp'
    user 'root'
    code <<-EOH
        'vm.dirty_expire_centisecs=20000' >> /etc/sysctl.conf
        sysctl -p
        EOH
    not_if 'grep vm.dirty_expire_centisecs=20000 /etc/sysctl.conf' 
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

# bash 'create automate init-config' do
#     cwd '/usr/bin'
#     code <<-EOH
#         sudo ./chef-automate init-config
#         EOH
# end

execute 'chef-automate init-config' do
    not_if 'chef-automate status'
end
    
bash 'create automate deploy' do
    cwd '/usr/bin'
    code <<-EOH
        sudo ./chef-automate deploy config.toml
        EOH
end

bash 'configure data_collector' do
    cwd '/usr/bin'
    code <<-EOH
        export TOK=`chef-automate admin-token`
        echo $TOK > /usr/bin/automate.tok
        EOH
end

