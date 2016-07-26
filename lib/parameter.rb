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

# Provisioningで使用する各種パラメータのコンテナクラス

class Parameter

  # Provisioningを行うenvironment名
  attr_writer :environment

  # Provisioningを行うrole名
  attr_writer :role

  # 初回実行用run_listデータ
  attr_writer :init_run_list

  # 全environment・全roleのrun_listデータ
  attr_writer :run_list

  # 全environment・全roleのattributeデータ
  attr_writer :attributes_list

  # node固有のattribute
  attr_writer :node_attributes_list

  def initialize(environment, role)
    @index = 0
    @environment = environment
    @role = role
  end

  # Provisioning対象となる（複数の）ホストを設定
  def hosts(host_type, hosts, init_user, admin_user)
    @hosts = []
    hosts.each do |node|
      @hosts.push(host_type.new(node, init_user, admin_user))
    end
  end

  def has_next?
    @index < @hosts.length
  end

  def item
    @hosts[@index]
  end

  def next_item
    value = @hosts[@index]
    @index += 1
    value
  end

  def init_run_list
    @init_run_list
  end

  #environmentとroleにマッチするrun_listを返す
  def run_list
    # runlistの作成
    run_list = []

    ['common', @role].each do |_role|
      ['default', @environment].each do |_env|

        if !@run_list.has_key?(_role) || !@run_list[_role].has_key?(_env)
          puts("ERROR: @run_list['#{_role}']['#{_env}'] does not exist.")
          exit
        end

        run_list.concat(@run_list[_role][_env])
      end
    end
    run_list
  end

  #environmentとroleにマッチするattributesを返す
  def attributes
    attributes = @hosts[@index].attributes

    ['common', @role].each do |_role|
      ['default', @environment].each do |_env|

        if !@attributes_list.has_key?(_role) || !@attributes_list[_role].has_key?(_env)
          puts("ERROR: @attributes_list['#{_role}']['#{_env}'] does not exist.")
          exit
        end

        attributes = Chef::Mixin::DeepMerge.deep_merge(
          attributes, @attributes_list[_role][_env]
        )
      end
    end
    attributes
  end
end
