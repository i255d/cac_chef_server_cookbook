#!/usr/bin/pwsh
#Set-Content $scriptPath ((Get-Content $scriptPath -raw) -replace "\r") -Encoding utf8

$hostname = hostname
if($hostname -match 'dev'){
    $azureEnv = 'dev'
    $envIPSub = '10.14.40.'
    $envDomain = ".dev.local"
}
elseif($hostname -match 'qa'){
    $azureEnv = 'qa'
    $envIPSub = '10.14.80.'
    $envDomain = ".qa.local"
}
elseif($hostname -match 'proda'){
    $azureEnv = 'proda'
    $envIPSub = '10.13.8.'
    $envDomain = ".acuitylightinggroup.com"
}

$automate = @'
default['chef_automate']['chef_automate_fqdn'] = '__automateFQDN__'
default['chef_automate']['chef_automate_host'] = '__automate__'
default['chef_automate']['chef_automate_ip'] = '__automateIP__'
default['chef_automate']['chef_server_fqdn'] = '__chefFQDN__'
default['chef_automate']['chef_server_host'] = '__chef__'
default['chef_automate']['chef_server_ip'] = '__chefIP__'
'@

$chefdev = 'chef-' + $azureEnv + '-01'
$autodev = 'chef-' + $azureEnv + '-02'
$chefdevFqdn = $chefdev + $envDomain
$autodevFqdn = $autodev + $envDomain
$chefIpDev =  $envIPSub + '100'
$autoIpDev = $envIPSub + '101'

$automate2 = $automate.Replace('__chef__',$chefdev)
$automate3 = $automate2.Replace('__automate__', $autodev)
$automate4 = $automate3.Replace('__chefIP__', $chefIpDev)
$automate5 = $automate4.Replace('__automateIP__', $autoIpDev)
$automate6 = $automate5.Replace('__automateFQDN__', $autodevFqdn)
$automateOut = $automate6.Replace('__chefFQDN__', $chefdevFqdn)

$chef =  @'
default['chef_server']['chef_server_fqdn'] = '__chefFQDN__'
default['chef_server']['chef_server_host'] = '__chef__'
default['chef_server']['chef_server_ip'] = '__chefIP__'
default['chef_server']['chef_automate_fqdn'] = '__automateFQDN__'
default['chef_server']['chef_automate_host'] = '__automate__'
default['chef_server']['chef_automate_ip'] = '__automateIP__'
'@

$automate2 = $chef.Replace('__chef__',$chefdev)
$automate3 = $automate2.Replace('__automate__', $autodev)
$automate4 = $automate3.Replace('__chefIP__', $chefIpDev)
$automate5 = $automate4.Replace('__automateIP__', $autoIpDev)
$automate6 = $automate5.Replace('__automateFQDN__', $autodevFqdn)
$chefOut = $automate6.Replace('__chefFQDN__', $chefdevFqdn)


$chefOut 
#> '/tmp/cookbooks/chef_server/attributes/default.rb'

$automateOut 
#> '/tmp/cookbooks/chef_automate/attributes/default.rb'
