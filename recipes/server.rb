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
end

directory "/etc/logstash/keys" do
  owner "logstash"
  group "logstash"
  mode "0600"
end

remote_file "Copy cert chain" do
  path "/etc/logstash/keys/DigiCertCA.crt"
  source "/etc/ssl/certs/DigiCertCA.crt"
  owner 'logstash'
  group 'logstash'
  mode "0400"
end

remote_file "Copy ssh cert" do
  path "/etc/logstash/keys/#{node['service']['ssl_key_name']}.crt"
  source "/etc/ssl/certs/#{node['service']['ssl_key_name']}.crt"
  owner 'logstash'
  group 'logstash'
  mode "0400"
end

remote_file "/etc/logstash/keys/#{node['service']['ssl_key_name']}.key" do
  path "/etc/logstash/keys/#{node['service']['ssl_key_name']}.key"
  source "/etc/ssl/private/#{node['service']['ssl_key_name']}.key"
  owner 'logstash'
  group 'logstash'
  mode "0400"
end

template "/etc/logstash/conf.d/server.conf" do
  source "logstash.conf.erb"
  variables( :config => node[:logstash][:server] )
  notifies :restart, "service[logstash]"
end
