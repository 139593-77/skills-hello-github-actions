require 'json'
require 'chef/mixin/powershell_out'
require 'timeout'

# Assemble the databag name based on attributes
appid = node['appid']
application = node['appname']
environment = node['environment']
data_bag = data_bag_item(appid + '_db_' + application, appid + '-' + environment + '-secrets')

# Retrieve secrets into variables
var_identitytoken = data_bag[node['artifactory_service_account'] + '-identitytoken']

# Locate JSON file with wildcard handling
file_path = Dir.glob('C:/cookbooks/7.7_install_uninstall.json').first
raise 'JSON file not found' unless file_path

# Read and Parse JSON Data
file = File.read(file_path)
json_data = JSON.parse(file)
# Check if json_data is empty
if json_data.empty?
  raise 'Invalid Json'
end

installpipeline = !json_data['wbg_a001c7_loaniq']['install_uninstall'].empty? ? json_data['wbg_a001c7_loaniq']['install_uninstall'] : nil

if json_data['wbg_a001c7_loaniq']['install_uninstall'].empty?
  raise 'Invalid Json - Add values for Install_Uninstall Block'
end

# Creation of folders (devops, devops/powershell_scripts, devops/sql_scripts)
#
[installpipeline['local_devops_windows_softwares_path']].each do |folder|
  directory folder do
    recursive true
    action :create
  end
end

def install_software(software, installpipeline, var_identitytoken)
  Chef::Log.info("software -- #{software}")
  install_type = ''
  options_list = ''
  options_list = installpipeline["#{software}"]['options_list']
  resource_type = installpipeline["#{software}"]['resource_type']
  software_link = installpipeline["#{software}"]['art_link']
  devops_path = installpipeline['local_devops_windows_softwares_path']
  drive = installpipeline['targetDrive']
  Chef::Log.info("software_link -- #{software_link}")
  # Check if the software is already installed
  ::Chef::DSL::Recipe.send(:include, Chef::Mixin::PowershellOut)
  service_start_or_stop_action = <<-EOF
    function Format-AnsiColor {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(
          Mandatory = $true,
          ValueFromPipeline = $true
        )]
        [AllowEmptyString()]
        [String]
        $Message ,
        [Parameter()]
        [ValidateSet(
              'normal display'
              ,'bold'
              ,'underline (mono only)'
              ,'blink on'
              ,'reverse video on'
              ,'nondisplayed (invisible)'
        )]
        [Alias('attribute')]
        [String]
        $Style ,
        [Parameter()]
        [ValidateSet(
              'black'
              ,'red'
              ,'green'
              ,'yellow'
              ,'blue'
              ,'magenta'
              ,'cyan'
              ,'white'
        )]
        [Alias('fg')]
        [String]
        $ForegroundColor ,
        [Parameter()]
        [ValidateSet(
              'black'
              ,'red'
              ,'green'
              ,'yellow'
              ,'blue'
              ,'magenta'
              ,'cyan'
              ,'white'
        )]
        [Alias('bg')]
        [String]
        $BackgroundColor
    )
    Begin {
      $e = [char]27
      $attrib = @{
        'normal display' = 0
        'bold' = 1
        'underline (mono only)' = 4
        'blink on' = 5
        'reverse video on' = 7
        'nondisplayed (invisible)' = 8
      }
      $fore = @{
            black = 30
            red = 31
            green = 32
            yellow = 33
            blue = 34
            magenta = 35
            cyan = 36
            white = 37
      }
      $back = @{
            black = 40
            red = 41
            green = 42
            yellow = 43
            blue = 44
            magenta = 45
            cyan = 46
            white = 47
      }
    }
    Process {
        $formats = @()
        if ($Style) {
            $formats += $attrib[$Style]
        }
        if ($ForegroundColor) {
            $formats += $fore[$ForegroundColor]
        }
        if ($BackgroundColor) {
            $formats += $back[$BackgroundColor]
        }
        if ($formats) {
            $formatter = "$e[$($formats -join ';')m"
        }
        "$formatter$_"
      }
    }
    Format-AnsiColor -Message 'Hey there' -Style Bold -ForegroundColor Red
    $sw_name = "#{software}" + "*"
    $software = Get-Package -Name $sw_name -ErrorAction SilentlyContinue
    if (${software}.Name -like "$sw_name") {
      Write-Host "Software is already installed"
      echo "Software is already installed" >#{drive}/devops/software_status.txt
    }
    $resType = "#{resource_type}"
    if (${resType} -eq 'python') {
      $python_name = 'Python*'
      $python_status = Get-Package -Name $python_name -ErrorAction SilentlyContinue
      if (!$python_status) {
        Write-Host "Python is not installed and hence can not proceed with the installation of the #{software}"
        echo "Python is not installed" >#{drive}/devops/python_status.txt
      }
    }
    # Format-AnsiColor -Message 'Hey there' -Style 'normal display' -ForegroundColor Black
    Format-AnsiColor -Message 'Hey there' -Style 'normal display' -ForegroundColor White
    EOF
  service_stop_start_action_status = powershell_out(service_start_or_stop_action).stdout.chomp()
  Chef::Log.info("Services action status in timeout loop--#{service_stop_start_action_status}")
  statusFile = "#{drive}/devops/software_status.txt"
  if File.exist?(statusFile)
    Chef::Log.info('Software is alredy installed...exiting')
    File.delete(statusFile)
    return
  else
    Chef::Log.info('Software is not installed...proceeding')
  end

  if resource_type == 'python'
    pythonStatusFile = "#{drive}/devops/python_status.txt"
    if File.exist?(pythonStatusFile)
      Chef::Log.info("Python is not installed and hence can not proceed with the installation of the #{software}")
      File.delete(pythonStatusFile)
      return
    else
      Chef::Log.info("Python is installed and hence proceeding with the installation of the #{software}")
      software_path = "#{installpipeline['local_devops_windows_softwares_path']}" + "\\#{installpipeline["#{software}"]['package_name']}"
      Chef::Log.info("software_path -- #{software_path}")
      remote_file "#{software_path}" do
        source "#{software_link}"
        action :create_if_missing
        headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
        sensitive true
      end
      python_command = "#{installpipeline["#{software}"]['command']}"
      batch "Install Python Module #{software}" do
        code "#{python_command}"
        cwd "#{devops_path}"
        timeout 600
        ignore_failure true
      end
    end
  elsif resource_type == 'windows_package'
    Chef::Log.info("installing windows package software #{software}...")
    if "#{installpipeline["#{software}"]['package_type']}" == 'msi'
      install_type = "#{installpipeline["#{software}"]['package_type']}"
    elsif "#{installpipeline["#{software}"]['package_type']}" == 'exe'
      install_type = 'custom'
    end

    Chef::Log.info("install_type -- #{install_type}")
    Chef::Log.info("options_list -- #{options_list}")
    software_path = "#{installpipeline['local_devops_windows_softwares_path']}" + "\\#{installpipeline["#{software}"]['package_name']}"
    Chef::Log.info("software_path -- #{software_path}")

    remote_file "#{software_path}" do
      source "#{software_link}"
      action :create_if_missing
      headers(
        'Authorization' => "Bearer #{var_identitytoken}"
      )
      sensitive true
    end

    windows_package "Install - #{software}" do
      installer_type :"#{install_type}"
      source "#{software_path}"
      options "#{options_list}"
      ignore_failure true
    end
  end
  if software == 'OracleClient'
    Chef::Log.info('--------------- Checking if Oracle Client is already installed -----------------')
    oracle_base = "#{installpipeline["#{software}"]['installation_dir']}"
    deinstall_path = "#{installpipeline["#{software}"]['deinstall_path']}" + '\\deinstall.bat'
    if ::File.exist?(deinstall_path)
      Chef::Log.info('Oracle Client is already installed. Proceeding with uninstallation.')
      # Run the deinstall.bat file to uninstall Oracle Client
      batch 'Uninstall Oracle Client' do
        cwd "#{installpipeline["#{software}"]['deinstall_path']}"
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
    software_path = "#{installpipeline['local_devops_windows_softwares_path']}" + "\\#{installpipeline["#{software}"]['response_file']}"
    response_file_link = "#{installpipeline["#{software}"]['response_link']}"
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
    zipfile_name = "#{archive_dest}" + "\\#{installpipeline["#{software}"]['package_name']}"

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
      code ".\\setup.exe -silent -nowait -ignoreSysPrereqs -ignorePrereq -waitForCompletion -force -responseFile #{software_path}"
    end
    Chef::Log.info('--------------- Successfully Installed Oracle Client -----------------')
  end
  if software == 'ReflectionClient'
    Chef::Log.info('--------------- Installing ReflectionClient -----------------')
    # Downloading Reflection client zip file
    zipfile_name = "#{installpipeline['local_devops_windows_softwares_path']}" + '/Reflection_Secure_Client.zip'
    remote_file "#{zipfile_name}" do
      source "#{software_link}"
      action :create_if_missing
      headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
      sensitive true
    end

    # Extract the zipfile
    destination_folder = "#{installpipeline['local_devops_windows_softwares_path']}" + '/Reflection_Secure_Client'
    archive_file 'Extract Reflection Client file' do
      path "#{zipfile_name}"
      destination "#{destination_folder}"
      overwrite true
    end

    client_installable = "#{destination_folder}" + "/#{installpipeline["#{software}"]['package_name']}"
    windows_package "Install - #{software}" do
      installer_type :msi
      source "#{client_installable}"
      options "#{options_list}"
    end
    Chef::Log.info('--------------- Successfully Installed ReflectionClient -----------------')
    Chef::Log.info('--------------- Installing ReflectionClient Patch -----------------')
    # Downloading Reflection client patch zip file
    zipfile_name = "#{installpipeline['local_devops_windows_softwares_path']}" + '/p724254.zip'
    software_link = "#{installpipeline["#{software}"]['patch_art_link']}"
    remote_file "#{zipfile_name}" do
      source "#{software_link}"
      action :create_if_missing
      headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
      sensitive true
    end

    # Extract the zipfile
    destination_folder = "#{installpipeline['local_devops_windows_softwares_path']}" + '/Reflection_Secure_Client'
    archive_file 'Extract Reflection Client Patch file' do
      path "#{zipfile_name}"
      destination "#{destination_folder}"
      overwrite true
    end

    patch_installable = "#{destination_folder}" + "/#{installpipeline["#{software}"]['patch_package_name']}"
    options_list = "#{installpipeline["#{software}"]['patch_options_list']}"
    windows_package "Install - #{software} Patch" do
      installer_type :custom
      source "#{patch_installable}"
      options "#{options_list}"
      ignore_failure true
    end
    Chef::Log.info('--------------- Successfully Installed ReflectionClient Patch -----------------')
  end
  if software == 'Tomcat'
    # Downloading zip file
    zipfile_name = "#{devops_path}" + "/#{installpipeline["#{software}"]['package_name']}"
    remote_file "#{zipfile_name}" do
      source "#{software_link}"
      action :create_if_missing
      headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
      sensitive true
    end

    # Extract tomcat zipfile
    destination_folder = 'E:/LoanIQ/'
    archive_file 'Extract Apache tomcat file' do
      path "#{zipfile_name}"
      destination "#{destination_folder}"
      overwrite true
    end
  end
  if software == 'Control-M'
    Chef::Log.info('Calling Control-M recipe')
    include_recipe 'wbg_a00964_windows_controlm::default'
    Chef::Log.info('Successfully installed Control-M software')
  end
  if software == 'Oracle-Sqldeveloper'
    zipfile_name = "#{devops_path}" + "/#{installpipeline["#{software}"]['package_name']}"
    remote_file "#{zipfile_name}" do
      source "#{software_link}"
      action :create_if_missing
      headers(
          'Authorization' => "Bearer #{var_identitytoken}"
        )
      sensitive true
    end

    destination_folder = "#{installpipeline["#{software}"]['Install_dir']}"
    path_parts = destination_folder.split('\\')
    desired_path = path_parts[0..-2].join('\\')
    # checking oracle client path existence
    begin
      if Dir.exist?(desired_path)
        Chef::Log.info("The directory '#{desired_path}' exist.")
      else
        raise "The directory '#{desired_path}' does not exist. Kindly ensure that the Oracle client has to be installed as a pre-requisite for this sql developer and check the path existence."
      end
    rescue => e
      Chef::Log.fatal("\033[1;31m#{e.message}\033[0m")
      raise
    end
    # Extract sqldeveloper zipfile
    archive_file 'Extract oraclesqldeveloper file' do
      path "#{zipfile_name}"
      destination "#{destination_folder}"
      overwrite true
    end

    ruby_block 'Create SQL Developer shortcut for all users' do
      block do
        require 'win32ole'
        shell = WIN32OLE.new('WScript.Shell')
        shortcut = shell.CreateShortcut('C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\SQL Developer.lnk')
        shortcut.TargetPath = "#{destination_folder}\\sqldeveloper\\sqldeveloper.exe"
        shortcut.WorkingDirectory = "#{destination_folder}\\sqldeveloper"
        shortcut.Save
      end
      action :run
    end
  end
end

software_list = installpipeline['softwares_list']

software_list.each do |software|
  begin
    install_software(software, installpipeline, var_identitytoken)
  rescue => e
    puts "Unexpected error installing #{software}: #{e.message}"
  end
end

delete_devops_path = installpipeline['local_devops_windows_softwares_path']

directory delete_devops_path do
  action :delete
  recursive true
  only_if { ::File.directory?(delete_devops_path) }
end
