# recipes/default.rb

component_type = 'atoti-mr'
versioned_jar = "#{component_type}-1.0.0-12345-6.jar"
source_path = "/path/to/dir1/#{versioned_jar}"
destination_dir = '/path/to/dir2'
destination_path = "#{destination_dir}/#{versioned_jar}"
symlink_name = "#{destination_dir}/#{component_type}-current.jar"

# 1. Copy the JAR file
execute 'copy_jar_file' do
  command "cp #{source_path} #{destination_path}"
  not_if { ::File.exist?(destination_path) }
end

# 2. Create the symlink only if `createSymLink` flag is yes
create_symlink = node['createSymLink'] # This could be pulled from node attributes or passed as an environment variable

if create_symlink == 'yes'
  execute 'create_symlink' do
    command "ln -sf #{destination_path} #{symlink_name}"
  end
end
