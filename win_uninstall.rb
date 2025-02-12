# +---------------------------------------------------------------------------------
# |  Cookbook:: wbg_a0041a_rtce
# |  Recipe::  win_uninstall
# |  DESCRIPTION: This script can be used for uninstalling softwares on windows
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
require 'win32/registry'

log 'message' do
  message "Execution of #{cookbook_name}"
  level :info
end

# Read data from json file
file = File.read('C:\\cookbooks\\install_uninstall.json')
registry_paths = ['SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall', 'SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall']
uninstall_string = nil

# Parse JSON Data
json_data = JSON.parse(file)

# Check if json_data is empty
if json_data.empty?
  raise 'Invalid Json'
end

install_uninstall = json_data['wbg_a0041a_rtce']['install_uninstall']

# Check if install_uninstall is empty

if install_uninstall.empty?
  raise 'Invalid Json - Add install_uninstall key for install_uninstall softwares'
end

install_uninstall['windows_softwares_list'].each do |software|
  package_path = "#{install_uninstall["#{software}"]['package_path']}"
  if ::File.exist?(package_path)
    uninstall_name = "#{install_uninstall["#{software}"]['uninstall_name']}"
    Chef::Log.info("Uninstall NAME: #{uninstall_name}")
    # install_dir = "#{install_uninstall["#{software}"]['installDir']}"
    Chef::Log.info("Uninstalling software: #{software}")
    uninstall_options = "#{install_uninstall["#{software}"]['uninstall_options']}"
    Chef::Log.info("Uninstall OPTIONS: #{uninstall_options}")
    registry_key = "#{install_uninstall["#{software}"]['registry_key']}"
    Chef::Log.info("REGISTRY KEY: #{registry_key}")
    if registry_key != ''
      # Fetch the UninstallString from the registry
      ruby_block "Fetch UninstallString for #{software}" do
        block do
          registry_paths.each do |registry_path|
            ::Win32::Registry::HKEY_LOCAL_MACHINE.open(registry_path) do |reg|
              reg.each_key do |key, _wtime|
                k = reg.open(key)
                begin
                  display_name = k['DisplayName']
                rescue
                  next
                else
                  display_name = k['DisplayName']
                end
                if display_name == uninstall_name
                  uninstall_string = k["#{registry_key}"]
                  break
                end
              end
            end
          end

          if uninstall_string
            if uninstall_string.index('"')
              Chef::Log.info('CONTAINS DOUBLE QUOTES')
              uninstall_string += uninstall_options
            else
              Chef::Log.info('NO DOUBLE QUOTES')
              uninstall_string = '"' + uninstall_string + '"'
              uninstall_string += uninstall_options
            end
            Chef::Log.info("UninstallString for #{software}: #{uninstall_string}")
          else
            Chef::Log.warn("UninstallString for #{software} not found.")
          end
        end
        action :run
      end
    else
      uninstall_string = "#{install_uninstall["#{software}"]['uninstall_options']}"
    end
    execute "Run Uninstallation of #{software}" do
      command lazy { "#{uninstall_string}" }
    end
  else
    Chef::Log.error("#{software} is not installed and hence exiting")
  end
end
