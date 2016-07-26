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

# Provisioningの実行
def execute(host_name, run_list, attributes, connection)
  data_bag_key = Chef::Config[:encrypted_data_bag_secret]

  # Chefのmachineリソースにてchef-provisioningを実行
  machine "#{host_name}" do
    machine_options :transport_options => connection
    add_machine_options :convergence_options => {:chef_version => 'true'}

    run_list run_list
    attributes attributes
    files '/etc/chef/encrypted_data_bag_secret' => data_bag_key if File.exist?(data_bag_key)

    converge true
    action [:converge]
  end
end

# ProvisioningをSSH経由で実行する
def run_provisioning(parameter)
  while parameter.has_next?
    host = parameter.item
    
    attributes = parameter.attributes
    host_name = host.host_name

    # Provisioning用アカウントが無い場合は、初回run_listを実行
    unless host.can_login?
      execute(host_name, 
          parameter.init_run_list,
          attributes, 
          host.init_connection
      )
    end

    # environment, roleに該当するrun_listを実行
    execute(host_name,
        parameter.run_list,
        attributes, 
        host.admin_connection
    )
    parameter.next_item
  end
end
