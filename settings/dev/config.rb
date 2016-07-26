current_dir = File.dirname(__FILE__)
root_dir    = "#{current_dir}/../.."

local_mode      true
log_level       :error
cookbook_path   ["#{root_dir}/_tmp/work-cookbooks"]
cache_path      "#{root_dir}/_tmp/local-mode-cache"
file_cache_path "#{root_dir}/_tmp"
chef_repo_path  "#{root_dir}/_tmp"
config_dir      "#{root_dir}/_tmp"

data_bag_path   "#{current_dir}/data_bags"

knife[:secret_file] = "#{current_dir}/data_bags/_key/data_bag_key"
knife[:editor]      = "vim"
encrypted_data_bag_secret knife[:secret_file]
