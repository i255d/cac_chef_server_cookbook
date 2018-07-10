bash 'iptables clear' do
    cwd '/tmp'
    code <<-EOH
        iptables-save > /home/abl/iptables.save
        iptables -F
        EOH
    not_if "sudo iptables -L -n | grep '0 references'"
end