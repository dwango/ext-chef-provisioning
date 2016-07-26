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
from_file("#{@root_dir}/lib/host.rb")

# SSH接続でProvisioningする場合のコンテナクラス
class SshHost < Host

  def init_connection
    connection(@init_user)
  end

  def admin_connection
    connection(@admin_user)
  end

  # chef-provisioning-ssh で指定する接続情報を返す
  def connection(user)
    options = {
      'ip_address' => @host['host'],
      'username' => user['user'],
      'ssh_options' => {
        'port' => @host['port']
      }
    }

    if user['key'].empty?
      options['ssh_options']['password'] = user['pass']
    else
      options['ssh_options']['keys'] = [user['key']]
      options['ssh_options']['passphrase'] = user['pass']
    end

    options
  end

  # 指定されたユーザー情報でSSHログインできるかをチェックする
  def can_login?
    begin
      if @admin_user['key'].empty?
        # パスワードでログイン
        Net::SSH.start(@host['host'], @admin_user['user'], :port => @host['port'], :password => @admin_user['pass'], :number_of_password_prompts => 0) do |ssh|
          puts("#{@admin_user['user']} exists.")
        end
        return true
      else
        # 鍵認証でログイン
        Net::SSH.start(@host['host'], @admin_user['user'], :port => @host['port'], :keys => @admin_user['key'], :passphrase => @admin_user['pass'], :number_of_password_prompts => 0) do |ssh|
          puts("#{@admin_user['user']} exists.")
        end
        return true
      end

    rescue
      puts("#{@admin_user['user']} does not exist.")
      return false
    end
  end
end

@host_type = SshHost
