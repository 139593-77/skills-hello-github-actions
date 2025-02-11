# +---------------------------------------------------------------------------------
# |  Cookbook:: wbg_clm
# |  Recipe::  service_restart
# |  DESCRIPTION: This script can be used for restarting services on windows
# +---------------------------------------------------------------------------------

##########################################################################
# Disable recipe check
if recipe_disabled?(cookbook_name, recipe_name, size: 2)
  Chef::Log.info("[\"#{cookbook_name}::#{recipe_name}\"] skipped due to disabling")
  return
end
##########################################################################

require 'chef/mixin/powershell_out'
require 'timeout'

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
  # Define the path to the JSON file
  $jsonFilePath = "C:\\cookbooks\\services.json"

  # Read the JSON file content
  $jsonContent = Get-Content -Path $jsonFilePath -Raw

  # Convert the JSON content to a PowerShell object
  $jsonObject = $jsonContent | ConvertFrom-Json

  # Access the key-value pairs
  $service_action = $jsonObject.wib_devops.services.Action
  $json_service = $jsonObject.wib_devops.services.servicename
  $is_svp = $jsonObject.wib_devops.services.isSVP
  $service_type = $jsonObject.wib_devops.services.${json_service}.service_type
  $service = Get-Service -Name $json_service -ErrorAction SilentlyContinue
  Write-Host "Service Type: $service_type"
  if ($service_type -eq 'IIS') {
    iisreset
    iisreset /status
    Format-AnsiColor -Message 'Hey there' -Style 'normal display' -ForegroundColor Black
    exit
  } elseif ($service.Length -eq 0) {
    Write-Host "Service does not exist"
    Format-AnsiColor -Message 'Hey there' -Style 'normal display' -ForegroundColor Black
    exit
  } else {
    if ($service_action -eq "Start") {
      if ($service.Status -ne "Running") {
        Start-Service -Name $json_service
      } else {
        Write-Host "Service $json_service is already running"
        Format-AnsiColor -Message 'Hey there' -Style 'normal display' -ForegroundColor Black
        exit
      }
      $service = Get-Service -Name $json_service -ErrorAction SilentlyContinue
      if ($service.Status -eq "Running") {
        Write-Host "PIV::Service $json_service is running"
      }
    } elseif ($service_action -eq "Stop") {
      if ($service.Status -ne "Stopped") {
        Stop-Service -Name $json_service
      } else {
        Write-Host "Service $json_service is already stopped"
        Format-AnsiColor -Message 'Hey there' -Style 'normal display' -ForegroundColor Black
        exit
      }
      $service = Get-Service -Name $json_service -ErrorAction SilentlyContinue
      if ($service.Status -eq "Stopped") {
        Write-Host "PIV::Service $json_service is stopped"
      }
    }
  }
  Format-AnsiColor -Message 'Hey there' -Style 'normal display' -ForegroundColor Black
EOF

service_stop_start_action_status = powershell_out(service_start_or_stop_action).stdout.chomp()
Chef::Log.info("Services action status in timeout loop-- #{service_stop_start_action_status}")
