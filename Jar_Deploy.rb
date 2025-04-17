
#
# +---------------------------------------------------------------------------------
# |  Recipe:: Jar_Deploy.rb
# |  Json:: appname.json
# |  DESCRIPTION: Deployment of Jar Package  in the linux server.
# |
# +---------------------------------------------------------------------------------

require 'json'

# Locate JSON file with wildcard handling
file_path = Dir.glob('/tmp/cookbooks/jar_deployment*.json').first
raise 'JSON file not found' unless file_path

# Read and Parse JSON Data
json_file = File.read(file_path)
json_data = JSON.parse(json_file)
# Check if json_data is empty
if json_data.empty?
  raise 'Invalid Json'
end

jarPipeline = json_data['wib_devops']['jar_deployment']

["#{jarPipeline['source_artifact_file_loc']}", "#{jarPipeline['source_artifact_extract_loc']}", "#{jarPipeline['deploy_location']}"].each do |dir|
  directory dir do
    recursive true
    action :create
  end
end

symLinkToCreate = jarPipeline['symLinkToCreate']
component_type = jarPipeline['component_type']
groupname = jarPipeline['group_name']
username = jarPipeline['user_name']

# Define the secret path
# Note that "##kv_base##" will map to the vault path that the host is onboarded to, such as "a0113e-dev"
# artifactory_service_account = "#{jarPipeline['artifactory_service_account']}"
# vault_path = "#{jarPipeline['vault_path']}"
# secret_path = '##kv_base##/"'"#{vault_path}/#{artifactory_service_account}"'"'
# version = "#{jarPipeline['vault_version']}"
# login_info = WbcVault::CredentialHelper.vault_kv_get("#{secret_path}", get_version: "#{version}")
# Chef::Log.info("Vault details - #{login_info}")
# Save the secrets under that path as variables
# var_identitytoken = "#{login_info['identity-token']}"

# Cookbook file creation
cookbook_file File.join('/tmp/', 'a005d4-identity-token') do
  source 'default/encryption_keys/identity-token'
end.run_action(:create)

# Load encrypted data bag secret
data_bag = Chef::EncryptedDataBagItem.load_secret(File.join('/tmp/', 'a005d4-identity-token'))

# Set identity token as node attribute
node.default['var_identitytoken'] = data_bag
var_identitytoken = node['var_identitytoken']

# Define an array of file URLs and destination paths
files = [
  { url: "#{jarPipeline['source_artifact_url_path']}/#{jarPipeline['source_artifact_file_name']}", path: "#{jarPipeline['source_artifact_file_loc']}" },
  { url: "#{jarPipeline['source_json_file_loc']}", path: "#{jarPipeline['source_artifact_file_loc']}" },
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
    action :create
  end
end

# Assign soure and destination file path for jar copy
source_file_local_fullpath = "#{jarPipeline['source_artifact_file_loc']}/#{jarPipeline['source_artifact_file_name']}"
destination_file_local_fullpath = "#{jarPipeline['deploy_location']}/#{jarPipeline['source_artifact_file_name']}"

# Copy the downloaded jar files to project path
if platform?('redhat')
  execute 'Copy files from source to destination' do
    command "cp -f #{source_file_local_fullpath} #{destination_file_local_fullpath} && chown #{username}:#{groupname} #{destination_file_local_fullpath}"
  end

  if symLinkToCreate == 'yes'
    execute 'create_symlink' do
      cwd "#{jarPipeline['deploy_location']}"
      command "ln -s #{jarPipeline['source_artifact_file_name']} #{component_type}-current.jar && chown #{username}:#{groupname} #{component_type}-current.jar"
    end
  end
end
