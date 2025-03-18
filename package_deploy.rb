
#
# +---------------------------------------------------------------------------------
# |  Recipe:: package_deploy.rb
# |  Json:: appname.json
# |  DESCRIPTION: Deployment of Package .
# |
# +---------------------------------------------------------------------------------

log 'message' do
  message "Execution of #{cookbook_name}"
  level :info
end

# json file assignment
package_deploy = !node['wib_devops']['package_deploy'].empty? ? node['wib_devops']['package_deploy'] : nil

if node['wib_devops']['package_deploy'].empty?
  raise 'Invalid Json - Add package_deploy key for package deployment'
end

["#{package_deploy['source_artifact_file_loc']}", "#{package_deploy['source_artifact_extract_loc']}/#{package_deploy['deploy_location']}", "#{package_deploy['install_source_drive']}#{package_deploy['deploy_location']}"].each do |dir|
  directory dir do
    recursive true
    action :create
  end
end

# Define the secret path
# Note that "##kv_base##" will map to the vault path that the host is onboarded to, such as "a0113e-dev"
artifactory_service_account = "#{package_deploy['artifactory_service_account']}"
vault_path = "#{package_deploy['vault_path']}"
secret_path = '##kv_base##/"'"#{vault_path}/#{artifactory_service_account}"'"'
version = "#{package_deploy['vault_version']}"
login_info = WbcVault::CredentialHelper.vault_kv_get("#{secret_path}", get_version: "#{version}")

# Save the secrets under that path as variables
var_identitytoken = "#{login_info['identity-token']}"

# Define an array of file URLs and destination paths
files = [
  { url: "#{package_deploy['source_artifact_url_path']}/#{package_deploy['current_package_version']}", path: "#{package_deploy['source_artifact_file_loc']}" },
  { url: "#{package_deploy['source_json_file_loc']}", path: "#{package_deploy['source_artifact_file_loc']}" },
]

files.each do |file|
  # Extract the filename from the URL
  filename = ::File.basename(file[:url])
  Chef::Log.info("filename - #{filename}")

  # Download the package and json files
  remote_file "#{file[:path]}/#{filename}" do
    source file[:url]
    headers(
      'Authorization' => "Bearer #{var_identitytoken}"
    )
    action :create_if_missing
  end
end

# uncompress file
archive_file "#{package_deploy['current_package_version']}" do
  path "#{package_deploy['source_artifact_file_loc']}/#{package_deploy['current_package_version']}"
  destination "#{package_deploy['source_artifact_extract_loc']}/#{package_deploy['deploy_location']}"
  overwrite true
  action :extract
end
sourceDirectory = "#{package_deploy['source_artifact_extract_loc']}"
source_folder = File.join("#{sourceDirectory}", "#{package_deploy['deploy_location']}", '/*')
Chef::Log.info("source_folder -- #{source_folder}")
destination_folder = File.join("#{package_deploy['install_source_drive']}#{package_deploy['deploy_location']}", '/')
Chef::Log.info("destination_folder -- #{destination_folder}")
# Execute below code if the server is windows
if platform?('windows')
  powershell_script 'Windows, copy directory from new version source to destination project directory' do
    code <<-EOH
      $ErrorActionPreference = 'Stop'
       Copy-Item -Path "#{source_folder}" -Destination "#{destination_folder}" -Recurse -Force
    EOH
    live_stream true
    timeout 600
    ignore_failure true
  end
else
  # Execute below code if the server is linux
  bash 'Linux, copy directory from new version source to destination project directory' do
    code <<-EOH
      cp -r #{source_folder} #{destination_folder}
    EOH
    live_stream true
    timeout 600
    ignore_failure true
  end
end
