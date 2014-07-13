#
# Cookbook Name:: chef-logstash
# Recipe:: server
#
# Copyright (C) 2014 Wouter de Vos
# 
# License: MIT
#
template "/opt/logstash/patterns/token" do
  source "token_pattern.erb"
  owner 'logstash'
  group 'logstash'
end

directory "/etc/ssl/private" do
  mode '0755'
end

file "/etc/ssl/certs/DigiCertCA.crt" do
  owner 'logstash'
  group 'logstash'
  mode '0400'
end

file "/etc/ssl/certs/#{node['service']['ssl_key_name']}.crt" do
  owner 'logstash'
  group 'logstash'
  mode '0400'
end

file "/etc/ssl/private/#{node['service']['ssl_key_name']}.key" do
  owner 'logstash'
  group 'logstash'
  mode '0400'
end

template "/etc/init/logstash.conf" do
  source "init_logstash.conf.erb"
  variables( :config => node[:logstash][:server] )
  notifies :restart, "service[logstash]"
end

template "/etc/logstash/conf.d/server.conf" do
  source "logstash.conf.erb"
  owner 'logstash'
  group 'logstash'
  variables( :config => node[:logstash][:server] )
  notifies :restart, "service[logstash]"
end
