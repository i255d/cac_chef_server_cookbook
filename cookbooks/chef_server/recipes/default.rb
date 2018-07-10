#
# Cookbook:: chef_server
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
include_recipe 'chef_server::iptables'
include_recipe 'chef_server::hostname'
include_recipe 'chef_server::server'