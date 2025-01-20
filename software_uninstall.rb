# Run the 'where' command to find the path of a software (e.g., 'python')
command = 'where /R "C:\Program Files\R" unins*.exe'

# Use the shell_out method to execute the command and capture the output
output = shell_out(command).stdout.strip

# Log the output to verify the result
log 'command_output' do
  message "The output of the 'where' command is: #{output}"
  level :info
end

# Example check: if the command output is non-empty, do something
if output.empty?
  log 'command_not_found' do
    message "'where uninst.exe' returned no result. R is not installed."
    level :warn
  end
else
  log 'command_found' do
    message "'where uninst.exe' found at: #{output}"
    level :info
  end
end

windows_package 'R' do
    action :remove
    installer_type :exe
    source output
    options '/S' # Silent uninstall option, modify as needed
  end
  