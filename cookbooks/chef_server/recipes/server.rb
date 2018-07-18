

remote_file '/tmp/chef-server-core-12.17.33-1.el7.x86_64.rpm' do
    source 'https://packages.chef.io/files/stable/chef-server/12.17.33/el/7/chef-server-core-12.17.33-1.el7.x86_64.rpm'
end

package 'install chef server' do
    source '/tmp/chef-server-core-12.17.33-1.el7.x86_64.rpm'
    action :install
    notifies :run, 'bash[chef reconfigure]', :immediately   
    not_if 'sudo chef-server-ctl status nginx|grep -G nginx:'
end

directory '/home/certs' do
    recursive true
end

bash 'chef reconfigure' do
    cwd '/tmp'
    code <<-EOH
        chef-server-ctl reconfigure
        EOH
    action :nothing
end

# bash 'create user dxi02' do
#     cwd '/tmp'
#     code <<-EOH
#         chef-server-ctl user-create dxi02 Dan Iverson dxi02@acuitysso.com '@password123' --filename /home/certs/dans-validator.pem
#         EOH
#     not_if 'chef-server-ctl user-list|grep -w dxi02' 
# end

execute 'chef-server-ctl user-create dxi02 Dan Iverson dxi02@acuitysso.com @password123 --filename /home/certs/dans-validator.pem' do
    not_if 'chef-server-ctl user-list|grep -w dxi02' 
end

# execute 'chef-automate init-config' do
#     not_if 'chef-automate status'
# end

bash 'create org acuityautomate' do
    cwd '/tmp'
    code <<-EOH
        chef-server-ctl org-create acuityautomate 'AcuityBrands Automate' --filename /home/certs/acuityautomate-validator.pem -a dxi02
        EOH
    not_if 'chef-server-ctl org-list|grep -w acuityautomate' 
end

bash 'create org acuity' do
    cwd '/tmp'
    code <<-EOH
        chef-server-ctl org-create acuity 'AcuityBrands' --association_user dxi02 --filename /home/certs/abl-validation.pem
        EOH
    not_if 'chef-server-ctl org-list|grep -w acuity' 
end

bash 'install chef manage' do
    cwd '/tmp'
    code <<-EOH
        chef-server-ctl install chef-manage
        chef-manage-ctl reconfigure --accept-license   
        EOH
    not_if { ::File.exist?('/var/log/chef-manage/web/config') }
end    

# bash 'import data collector' do
#     cwd '/user/bin'
#     code <<-EOH
#         $automateTok = cat /usr/bin/automate.tok
#         sudo chef-server-ctl set-secret data_collector token $automateTok
#         EOH
# end
execute '$automateTok = cat /usr/bin/automate.tok && sudo chef-server-ctl set-secret data_collector token $automateTok' do
    not_if 'sudo chef-server-ctl show-secret data_collector token'
end
