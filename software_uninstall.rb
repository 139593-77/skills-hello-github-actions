# Cookbook:: my_cookbook
# Recipe:: fetch_uninstall_string
# Description:: This recipe fetches the UninstallString from the registry for a specific software

# Define the software name and registry path

require 'win32/registry'
software_name = 'R for Windows 4.4.1'
registry_path = 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
uninstall_string = nil

# Fetch the UninstallString from the registry
ruby_block "Fetch UninstallString for #{software_name}" do
  block do
    
    uninstall_string = nil
    ::Win32::Registry::HKEY_LOCAL_MACHINE.open(registry_path) do |reg|
      reg.each_key do |key, _wtime|
        k = reg.open(key)
        display_name = k['DisplayName'] rescue nil
        if display_name == software_name
          uninstall_string = k['QuietUninstallString'] rescue nil
          break
        end
      end
    end

    if uninstall_string
      Chef::Log.info("UninstallString for #{software_name}: #{uninstall_string}")
    else
      Chef::Log.warn("UninstallString for #{software_name} not found.")
    end
  end
  action :run
end

uninstall_string = "\"C:\\Program Files\\R\\R-4.4.1\\unins000.exe\" /SILENT & rmdir /S /Q C:\\Mangesh\\tcs\\Chef\\cookbooks\\test2"
# uninstall_string = "dir /L . & ipconfig /all"

# Define the variable
my_command = "echo Hello, Chef!"

# Use the variable in the execute resource
execute 'run_custom_command' do
  command my_command
  action :run
end


execute "Run Uninstallation of #{software_name}" do
  
  command uninstall_string
  # command lazy { "dir /L . & ipconfig /all" }

end
