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

log 'message' do
  message "Execution of #{cookbook_name}"
  level :info
end

#
# +---------------------------------------------------------------------------------
# |  Set Node Json
# |
# +---------------------------------------------------------------------------------

source_json = !node['wib_devops']['install_uninstall'].empty? ? node['wib_devops']['install_uninstall'] : nil

if source_json.empty?
  raise 'Invalid Json'
end

# Set Json FileName
node.default['current_json_file_name'] = source_json['current_json_file_name']

# Fetch Current Json
include_recipe 'wib_devops_lib::fetch_current_json'

Chef::Log.info("current_json -- #{node['current_json_data']}")

# Update Json data
current_json = !node['current_json_data'].empty? ? node['current_json_data'] : nil

Chef::Log.info("install_uninstall -- #{current_json['wib_devops']['install_uninstall']}")

install_uninstall = !current_json['wib_devops']['install_uninstall'].empty? ? current_json['wib_devops']['install_uninstall'] : nil

if current_json.empty? || current_json['wib_devops']['install_uninstall'].empty?
  raise 'Invalid Json - Add install_uninstall key for Software Installation'
end

#
# +---------------------------------------------------------------------------------
# |  Create Directories
# |
# +---------------------------------------------------------------------------------

include_recipe 'wib_devops_lib::dir_creation'

#
# +---------------------------------------------------------------------------------
# |  Fetch Vault Artifactory Token
# |
# +---------------------------------------------------------------------------------

vault_enabled = if !install_uninstall['vault_enabled'].nil?
                  install_uninstall['vault_enabled']
                else
                  false
                end

if vault_enabled
  log_in_dark_blue('Vault is enabled')
  # Set vault_key and vault_key_version
  #
  node.default['vault_key'] = install_uninstall['vault_art_key']
  node.default['vault_key_version'] = install_uninstall['vault_art_key_version']

  include_recipe 'wib_devops_lib::fetch_vault_info'
  vault_art_info = node['vault_info']
  node.default['vault_info'] = {}

  if vault_art_info['token'].nil? || vault_art_info['expiry'].nil? || vault_art_info['username'].nil?
    log_in_red("Vault Art info not present \n Please pass the vault \n vault_key \n vault_key_version ")
    raise 'Vault Info not present'
  else
    log_in_dark_blue("Vault Art Info present \n #{vault_art_info}")
    var_identitytoken = vault_art_info['token']
  end
else
  log_in_dark_blue('Vault is not enabled')
  include_recipe 'wib_devops_lib::generate_art_token'
  Chef::Log.info("folder_path  : #{node['var_identitytoken']}")
  var_identitytoken = node['var_identitytoken']
end

#
# +---------------------------------------------------------------------------------
# |  Software Installation Pipeline
# |
# +---------------------------------------------------------------------------------

log_in_dark_blue("local_devops_path -- #{install_uninstall['local_devops_path']}")
devops_path = "#{install_uninstall['local_devops_path']}"
log_in_dark_blue("local_devops_windows_softwares_path -- #{install_uninstall['local_devops_windows_softwares_path']}")

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
log_in_dark_blue("targetDrive -- #{install_uninstall['targetDrive']}")

# Use the base recipes to set up common folders

# TODO
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
    log_in_dark_blue('--------------- Software to be installed via Powershell -----------------')

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
    log_in_dark_blue("software_link -- #{software_link}")
    software_path = "#{install_uninstall['local_devops_windows_softwares_path']}" + "/#{install_uninstall["#{software}"]['package_name']}"
    log_in_dark_blue("software_path -- #{software_path}")
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

    log_in_dark_blue("install_type -- #{install_type}")
    log_in_dark_blue("options_list -- #{options_list}")
    windows_package "Install - #{software}" do
      action :install
      installer_type :"#{install_type}"
      source "#{software_path}"
      options "#{options_list}"
      timeout 900
    end

    log_in_dark_blue("Installed Software -- #{software}")
  end

  # For ODAC Driver installation
  next unless software == 'ODACDriver'
    software_link = "#{install_uninstall["#{software}"]['art_link']}"
    Chef::Log.info("Art link for ODACDriver::#{software_link}")
    software_path = "#{install_uninstall['local_devops_windows_softwares_path']}" + "\\#{install_uninstall["#{software}"]['package_name']}"
    # Downloading zip file
    remote_file "#{software_path}" do
      source "#{software_link}"
      action :create_if_missing
      headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
      sensitive true
    end

    archive_dest = "#{devops_path}" + "\\#{software}"
    zipfile_name = "#{archive_dest}" + "\\#{install_uninstall["#{software}"]['package_name']}"
    # Expand odac installable archive
    archive_file 'ODAC zip' do
      path "#{zipfile_name}"
      destination "#{archive_dest}" + '\\package'
    end
    # Run the install.bat file to install ODAC Driver
    batch 'Install ODAC Driver' do
      cwd "#{install_uninstall["#{software}"]['deinstall_path']}"
      code <<-EOH
        echo y | deinstall.bat
      EOH
      action :run
    end
  end 

  # For Oracle Client Installation
  next unless software == 'OracleClient'
    Chef::Log.info('--------------- Checking if Oracle Client is already installed -----------------')
    oracle_base = "#{install_uninstall["#{software}"]['installation_dir']}"
    deinstall_path = "#{install_uninstall["#{software}"]['deinstall_path']}" + '\\deinstall.bat'
    if ::File.exist?(deinstall_path)
      Chef::Log.info('Oracle Client is already installed. Proceeding with uninstallation.')
      # Run the deinstall.bat file to uninstall Oracle Client
      batch 'Uninstall Oracle Client' do
        cwd "#{install_uninstall["#{software}"]['deinstall_path']}"
        code <<-EOH
          echo y | deinstall.bat
        EOH
        action :run
      end
      # Ensure all folders related to Oracle Client are deleted
      directory "#{oracle_base}" do
        action :delete
        recursive true
        only_if { ::File.directory?("#{oracle_base}") }
      end
      Chef::Log.info('--------------- Successfully Uninstalled Oracle Client old version -----------------')
    else
      Chef::Log.info('Oracle Client is not installed. Proceeding with installation.')
    end

    Chef::Log.info('--------------- Installing Oracle Client -----------------')
    software_path = "#{install_uninstall['local_devops_windows_softwares_path']}" + "\\#{install_uninstall["#{software}"]['response_file']}"
    software_link = "#{install_uninstall["#{software}"]['art_link']}"
    response_file_link = "#{install_uninstall["#{software}"]['response_link']}"
    tnasnames_flag = "#{install_uninstall["#{software}"]['tnsnames_flag']}"
    # Downloading response file
    remote_file "#{software_path}" do
      source "#{response_file_link}"
      action :create_if_missing
      headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
      sensitive true
    end

    archive_dest = "#{devops_path}" + "\\#{software}"
    zipfile_name = "#{archive_dest}" + "\\#{install_uninstall["#{software}"]['package_name']}"

    directory "#{archive_dest}" do
      action :create
      recursive true
    end

    directory "#{oracle_base}" do
      action :create
      recursive true
    end

    # Downloading oracle client zip file
    remote_file "#{zipfile_name}" do
      source "#{software_link}"
      action :create_if_missing
      headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
      sensitive true
    end

    # Expand oracle installable archive
    archive_file 'Oracle zip' do
      path "#{zipfile_name}"
      destination "#{archive_dest}" + '\\package'
    end
    batch 'Install oracle client' do
      cwd "#{archive_dest}" + '\\package\\client'
      timeout 900
      # code ".\\setup.exe -silent -nowait -ignoreSysPrereqs -ignorePrereq -waitForCompletion -force -responseFile #{software_path}"
      code ".\\setup.exe setup -silent -nowait -nowelcome -noconfig -nowait -responseFile #{software_path}"
    end
    Chef::Log.info('--------------- Successfully Installed Oracle Client -----------------')

    # Start for TNSNAMES config if corresponding flag is true
    if tnasnames_flag == 'true'
      # code for copying tnsnames.ora to oracle client directory
    end
  end # next unless end
end
