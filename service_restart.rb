# +---------------------------------------------------------------------------------
# |  Cookbook:: wbg_clm
# |  Recipe::  service_restart
# |  DESCRIPTION: This script can be used for restarting services on windows
# |
# +---------------------------------------------------------------------------------

##########################################################################
# Disable recipe check
if recipe_disabled?(cookbook_name, recipe_name, size: 2)
  Chef::Log.info("[\"#{cookbook_name}::#{recipe_name}\"] skipped due to disabling")
  return
end
##########################################################################

require 'json'

log 'message' do
  message "Execution of #{cookbook_name}"
  level :info
end

# Read data from json file
file = File.read('C:\\cookbooks\\services.json')

# Parse JSON Data
json_data = JSON.parse(file)

# Check if json_data is empty
if json_data.empty?
  raise 'Invalid Json'
end

services = json_data['wib_devops']['services']

# Check if services is empty

if services.empty?
  raise 'Invalid Json - Add services key for services softwares'
end

Chef::Log.info("local_devops_path -- #{services['local_devops_path']}")
Chef::Log.info("local_devops_artifacts_path -- #{services['local_devops_artifacts_path']}")

# Creation of folders (devops, devops/artifacts)
#
[services['local_devops_path'], services['local_devops_artifacts_path']].each do |folder|
  directory folder do
    recursive true
    action :create
  end
end

# Read the Action and ServiceName from the node attributes
action = services['Action']
service_name = services['servicename']

# Perform IIS Reset if ServiceName is IIS
if service_name == 'IIS'
  execute 'reset_iis' do
    command 'iisreset'
    action :run
    timeout 600
  end
else
  # For other services, check if the action is 'Start' or 'Stop'
  case action
  when 'Start'
    # Start the service only if it is not already running
    windows_service service_name do
      action :start
    end
  when 'Stop'
    # Stop the service only if it is not already stopped
    windows_service service_name do
      action :stop
    end
end
