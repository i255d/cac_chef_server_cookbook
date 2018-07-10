#
# Cookbook:: chef_automate
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
include_recipe 'chef_automate::iptables'
include_recipe 'chef_automate::hostname'
include_recipe 'chef_automate::server'