# Cookbook:: my_cookbook
# Recipe:: install_oracle_client
# Description:: Installs Oracle client on a Windows server

# Define variables
artifactory_base_url = 'https://artifactory.example.com/artifactory'
oracle_client_zip_url = "#{artifactory_base_url}/path/to/oracle_client.zip"
oracle_response_file_url = "#{artifactory_base_url}/path/to/response_file.rsp"
download_dir = 'C:\\temp\\oracle_client'
oracle_client_zip_path = "#{download_dir}\\oracle_client.zip"
oracle_response_file_path = "#{download_dir}\\response_file.rsp"
extracted_dir = "#{download_dir}\\extracted"

# Ensure the download directory exists
directory download_dir do
  recursive true
  action :create
end

# Step 1: Download Oracle client install package zip file from Artifactory
remote_file oracle_client_zip_path do
  source oracle_client_zip_url
  action :create
end

# Step 2: Download Oracle client response file from Artifactory
remote_file oracle_response_file_path do
  source oracle_response_file_url
  action :create
end

# Step 3: Extract Oracle client install package zip file using archive_file
archive_file 'Extract Oracle Client' do
  path oracle_client_zip_path
  destination extracted_dir
  action :extract
  overwrite true
end

# Step 4: Run setup.exe with the response file
execute 'Install Oracle Client' do
  command "#{extracted_dir}\\setup.exe -silent -responseFile #{oracle_response_file_path}"
  cwd extracted_dir
  action :run
end
