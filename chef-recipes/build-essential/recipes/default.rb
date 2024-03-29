#
# Cookbook Name:: build-essential
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/shell_out'

compiletime = node['build_essential']['compiletime']

case node['os']
when "linux"

  # on apt-based platforms when first provisioning we need to force
  # apt-get update at compiletime if we are going to try to install at compiletime
  if node['platform_family'] == "debian"
    execute "apt-get update" do
      action :nothing
      # tip: to suppress this running every time, just use the apt cookbook
      not_if do
        ::File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
        ::File.mtime('/var/lib/apt/periodic/update-success-stamp') > Time.now - 86400*2
      end
    end.run_action(:run) if compiletime
  end

  packages = %w{build-essential binutils-doc}

  packages.each do |pkg|
    r = package pkg do
      action ( compiletime ? :nothing : :install )
    end
    r.run_action(:install) if compiletime
  end

  %w{autoconf flex bison}.each do |pkg|
    r = package pkg do
      action ( compiletime ? :nothing : :install )
    end
    r.run_action(:install) if compiletime
  end
when "darwin"
  result = Chef::ShellOut.new("pkgutil --pkgs").run_command
  installed = result.stdout.split("\n").include?("com.apple.pkg.gcc4.2Leo")
  pkg_filename = File.basename(node['build_essential']['osx']['gcc_installer_url'])
  pkg_path = "#{Chef::Config[:file_cache_path]}/#{pkg_filename}"

  r = remote_file pkg_path do
    source node['build_essential']['osx']['gcc_installer_url']
    checksum node['build_essential']['osx']['gcc_installer_checksum']
    action ( compiletime ? :nothing : :create )
    not_if { installed }
  end
  r.run_action(:create) if compiletime

  r = execute "sudo installer -pkg \"#{pkg_path}\" -target /" do
    action ( compiletime ? :nothing : :run )
    not_if { installed }
  end
  r.run_action(:run) if compiletime
end
