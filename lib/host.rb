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

# Provisioningを行うホスト情報のコンテナクラス
class Host

  # ホストの接続情報を含んだHash
  attr_writer :host

  # 初回実行用ユーザー（rootユーザー等）
  attr_writer :init_user

  # Provisioning実行ユーザー
  attr_writer :admin_user

  # host固有のattributes
  attr_accessor :attributes
  
  # nodeのHashにはhost情報とattributeが混在しているので、分離して変数に代入する
  def initialize(node, init_user, admin_user)
    _node = node
    
    @host = _node['host']
    @init_user = init_user
    @admin_user = admin_user
    
    _node.delete('host')
    @attributes = _node
  end

  def host_name
    @host['name']
  end
end
