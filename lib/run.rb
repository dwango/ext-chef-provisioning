# 
# Copyright:: Copyright (c) 2016 DWANGO Co., Ltd. All Rights Reserved.
# License:: Apache License, Version 2.0
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

@root_dir = "#{File.dirname(__FILE__)}/.."

# 設定ファイルを読み込んでparameterに設定する
def load_parameter(driver)
  from_file("#{@root_dir}/lib/parameter.rb")
  from_file("#{@root_dir}/lib/host_#{driver}.rb")
  from_file("#{@root_dir}/settings/#{@environment}/_auth/auth.rb")

  parameter = Parameter.new(@environment, @role)
  parameter.hosts(@host_type, @hosts, @init_user, @admin_user)

  from_file("#{@root_dir}/settings/attributes_list.rb")
  parameter.attributes_list = @attributes_list

  from_file("#{@root_dir}/settings/run_list.rb")
  parameter.init_run_list = @init_run_list
  parameter.run_list      = @run_list

  return parameter
end

# cookbooksとsite-cookbooksを結合する
def merge_cookbooks(default_path, override_path, distribution_path)
  if File.exists? distribution_path then
    FileUtils.rm_r(distribution_path)
  end
  FileUtils.mkdir_p(distribution_path)

  FileUtils.cp_r(Dir.glob(default_path), distribution_path)
  FileUtils.cp_r(Dir.glob(override_path), distribution_path)
end

# Provisioning実行
def run(driver)
  with_driver driver
  parameter = load_parameter(driver)
  merge_cookbooks(
    "#{@root_dir}/cookbooks/*",
    "#{@root_dir}/site-cookbooks/*",
    "#{@root_dir}/_tmp/work-cookbooks/"
  )

  # "ssh"や"aws"等の手段でprovisioningを実行する
  from_file("#{@root_dir}/lib/run_#{driver}.rb")
  run_provisioning(parameter)
end
