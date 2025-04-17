#
# +---------------------------------------------------------------------------------
# |  Recipe:: sql_deploy.rb
# |  Json:: NA
# |  DESCRIPTION: Meerkat SQL deployment recipe to execute the sql queries.
# |
# +---------------------------------------------------------------------------------

log 'message' do
  message '===== Meerkat SQL deploy ====='
  level :info
end

# assign values to local variable from json file
local_db_hostname = node['wbg_a005d4_atoti']['sql_pipeline']['db_hostname']
local_db_port = node['wbg_a005d4_atoti']['sql_pipeline']['db_port']
local_sql_release_file_path = node['wbg_a005d4_atoti']['sql_pipeline']['sql_release_file_path']
local_env_type = node['wbg_a005d4_atoti']['sql_pipeline']['env_type']
local_domain = node['wbg_a005d4_atoti']['domain']
# vault_version = node['wbg_a005d4_atoti']['vault_version']
# artifactory_service_account = node['wbg_a005d4_atoti']['sql_pipeline']['artifactory_service_account']
db_service_account = node['wbg_a005d4_atoti']['sql_pipeline']['db_service_account']
source_artifact_url_path = node['wbg_a005d4_atoti']['sql_pipeline']['source_artifact_url_path']
deploy_files = node['wbg_a005d4_atoti']['sql_pipeline']['deployFiles'] # Attribute for the list of SQL files to execute
current_package_version = node['wbg_a005d4_atoti']['current_package_version']
fqdn = node['wbg_a005d4_atoti']['fqdn']

Chef::Log.info("local_db_hostname -- #{local_db_hostname}")
Chef::Log.info("local_db_port -- #{local_db_port}")
Chef::Log.info("local_sql_release_file_path -- #{local_sql_release_file_path}")
Chef::Log.info("local_env_type -- #{local_env_type}")
Chef::Log.info("domain -- #{local_domain}")
Chef::Log.info("Package Artifactory Path -- #{source_artifact_url_path}")
Chef::Log.info("List of SQL files to be deployed -- #{deploy_files}")
Chef::Log.info("current_package_version -- #{current_package_version}")
Chef::Log.info("db_service_account -- #{db_service_account}")
# Chef::Log.info("vault_version -- #{vault_version}")

# Define the secret path
# Note that "##kv_base##" will map to the vault path that the host is onboarded to, such as "a0113e-dev"

# secret_path = '##kv_base##/sql_creds/"'"#{artifactory_service_account}"'"'
# login_info = WbcVault::CredentialHelper.vault_kv_get("#{secret_path}", get_version: "#{vault_version}")
# Chef::Log.info("login_info - #{login_info}")

# Cookbook file creation
cookbook_file File.join('/tmp/', 'a005d4-identity-token') do
  source 'default/encryption_keys/identity-token'
end.run_action(:create)

# Load encrypted data bag secret
data_bag = Chef::EncryptedDataBagItem.load_secret(File.join('/tmp/', 'a005d4-identity-token'))

# Set identity token as node attribute
node.default['var_identitytoken'] = data_bag
var_identitytoken = node['var_identitytoken']
deploy_directory = node['wbg_a005d4_atoti']['sql_pipeline']['deploy_directory'] # Directory to download and extract the zip file

# Ensure the deploy directory exists
directory deploy_directory do
  recursive true
  action :create
end

# Download the zip file from the source_artifact_url_path
zip_file_path = "#{deploy_directory}/#{current_package_version}"
remote_file zip_file_path do
  source source_artifact_url_path
  headers('Authorization' => "Bearer #{var_identitytoken}")
  mode '0644'
  action :create
end

# Extract the zip file
execute 'Extract zip file' do
  command "unzip -o #{zip_file_path} -d #{deploy_directory}"
  cwd deploy_directory
  action :run
end

# Change directory to the DevOps directory
ruby_block 'Change directory to DevOps' do
  block do
    Dir.chdir(deploy_directory)
  end
  action :run
end

# Execute each SQL script in the deployFiles attribute
deploy_files.each do |sql_file|
  Chef::Log.info("Executing SQL script: #{deploy_directory}/Devops/#{sql_file}")
  tokens = sql_file.split('/')
  db_name = 'atoti_'
  db_name += tokens[1]
  Chef::Log.info("Db NAME::#{db_name}")
  bash "Execute SQL script #{sql_file}" do
    cwd "#{deploy_directory}/Devops"
    code <<-EOH
      export KRB5_CONFIG="/riskdata/Temp/#{local_domain}.krb5.conf"
      kinit -k -t "/riskdata/Temp/#{local_domain}.#{db_service_account}.keytab" #{db_service_account}@#{fqdn}
      /opt/mssql-tools18/bin/sqlcmd -S #{local_db_hostname},#{local_db_port}\\\\#{db_name} -i #{deploy_directory}/Devops/#{sql_file}
    EOH
    action :run
    timeout 900
    live_stream true
  end
end
