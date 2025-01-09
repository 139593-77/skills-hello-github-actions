# +---------------------------------------------------------------------------------
# |  Cookbook:: wib_devops
# |  Recipe::  win_install
# |  DESCRIPTION: This script can be used for installing softwares on windows
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
file = File.read('C:\\cookbooks\\install_uninstall.json')

# Parse JSON Data
json_data = JSON.parse(file)

# Check if json_data is empty
if json_data.empty?
  raise 'Invalid Json'
end

install_uninstall = json_data['wib_devops']['install_uninstall']

# Check if install_uninstall is empty

if install_uninstall.empty?
  raise 'Invalid Json - Add install_uninstall key for install_uninstall softwares'
end

# Assemble the databag name based on attributes
appid = node['appid']
application = node['appname']
environment = node['environment']
data_bag = data_bag_item(appid + '_db_' + application, appid + '-' + environment + '-secrets')

# Retrieve secrets into variables
var_identitytoken = data_bag[node['artifactory_service_account'] + '-identitytoken']

Chef::Log.info("local_devops_path -- #{install_uninstall['local_devops_path']}")
Chef::Log.info("local_devops_windows_softwares_path -- #{install_uninstall['local_devops_windows_softwares_path']}")

# Creation of folders (devops, devops/powershell_scripts, devops/windows_softwares)
#
[install_uninstall['local_devops_path'], install_uninstall['local_devops_powershell_scripts_path'], install_uninstall['local_devops_windows_softwares_path']].each do |folder|
  directory folder do
    recursive true
    action :create
  end
end

if install_uninstall['targetDrive'].empty?
  install_uninstall['targetDrive'] = 'C:'
end
Chef::Log.info("targetDrive -- #{install_uninstall['targetDrive']}")

# Use the base recipes to set up common folders

# check that we have enough disk space in our target binary directory

# check available disk space for log directory

install_uninstall['ps_file_list'].each do |powershell_script_file_name|
  local_ps_file_download_path = 'E:/devops/powershell_scripts/' + powershell_script_file_name

  # Copy Powershell scripts file from files/<file_name> to Local
  # Target -> node['local_ps_file_download_path']
  # Source ->  node['source_ps_file']
  #
  cookbook_file local_ps_file_download_path do
    source powershell_script_file_name
    mode '0755'
    action :create
  end
end

# install_uninstall['windows_softwares_list'].select{ |sw| install_uninstall['ps_sw'].include?(sw)}

install_uninstall['windows_softwares_list'].each do |software|
  # For each software
  # Only for Powershell installation softwares
  #
  if install_uninstall['ps_sw'].include?(software)
    Chef::Log.info('--------------- Software to be installed via Powershell -----------------')

    local_ps_file_download_path = 'E:/devops/powershell_scripts/' + software + '.ps1'

    # Execute script
    powershell_script "run Powershell script - #{software}.ps1" do
      cwd 'E:\\devops\\powershell_scripts'
      code "#{local_ps_file_download_path} #{install_uninstall['targetDrive']}"
      action :run
      live_stream true
      timeout 900
    end
  else
    # Only for softwares to be executed via Execute
    #
    Chef::Log.info('Other softwares')
    # Download software from artifactory.
    software_link = "#{install_uninstall["#{software}"]['art_link']}"
    Chef::Log.info("software_link -- #{software_link}")
    software_path = "#{install_uninstall['local_devops_windows_softwares_path']}" + "/#{install_uninstall["#{software}"]['package_name']}"
    Chef::Log.info("software_path -- #{software_path}")
    remote_file "#{software_path}" do
      source "#{software_link}"
      action :create
      headers(
        'Authorization' => "Bearer #{var_identitytoken}"
      )
      sensitive true
    end

    install_type = ''
    options_list = ''
    if "#{install_uninstall["#{software}"]['package_type']}" == 'msi'
      install_type = "#{install_uninstall["#{software}"]['package_type']}"
      options_list = "#{install_uninstall["#{software}"]['options_list']}"
    elsif "#{install_uninstall["#{software}"]['package_type']}" == 'exe'
      install_type = 'custom'
      # options_list = '/S'
      options_list = "#{install_uninstall["#{software}"]['options_list']}"
    end

    Chef::Log.info("install_type -- #{install_type}")
    Chef::Log.info("options_list -- #{options_list}")
    windows_package "Install - #{software}" do
      action :install
      installer_type :"#{install_type}"
      source "#{software_path}"
      options "#{options_list}"
      timeout 900
    end

    Chef::Log.info("Installed Software -- #{software}")
  end
end
