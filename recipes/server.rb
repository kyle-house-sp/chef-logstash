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

Chef::Log.info node["opsworks"]["instance"]["layers"][0] 

template "/etc/logstash/conf.d/server.conf" do
  source "logstash.conf.erb"
  owner 'logstash'
  group 'logstash'
  variables( :config => node[:logstash][:server] )
  notifies :restart, "service[logstash]"
  only_if { node["opsworks"]["instance"]["layers"][0] == 'logstash' }
end

directory "/opt/bin" do
  owner 'logstash'
  group 'logstash'
  mode '0755'
end

directory "/vol/cloudtrail/timestamp" do
  owner 'logstash'
  group 'logstash'
  mode '0755'
  action :create
  only_if { node["opsworks"]["instance"]["layers"][0] == 'logstash-cloudtrail' }
end

template "/opt/bin/extract_contrib.sh" do
  source 'extract_contrib.sh.erb'
  owner 'logstash'
  group 'logstash'
  mode '0755'
  action :create_if_missing
end

remote_file "/opt/logstash/logstash-contrib.tar.gz" do
  source node[:logstash][:contrib_link]
  owner 'logstash'
  group 'logstash'
  only_if { node["opsworks"]["instance"]["layers"][0] == 'logstash-cloudtrail' }
  notifies :run, "bash[extract-contrib]"
end

bash 'extract-contrib' do
  code '/opt/bin/extract_contrib.sh'
  user 'logstash'
  group 'logstash'
  action :nothing
end

template "/etc/logstash/conf.d/server-cloudtrail.conf" do
  source "cloudtrail.conf.erb"
  owner 'logstash'
  group 'logstash'
  notifies :restart, "service[logstash]"
  only_if { node["opsworks"]["instance"]["layers"][0] == 'logstash-cloudtrail' }
end

