ext-chef-provisioning
====
Chef Provisioningでのプロビジョニングを利用しやすくするための外部ツール

## Description

従来Chefを実行するには、スタンドアロンで動かすChef Solo（＋Knife Solo）か、サーバーが必要なChef Serverのどちらかで実行していましたが、
Chef Soloは 今後メンテナンスされなくなってしまいました。そこでその代替として利用できるのがChef Provisioningです。
これを使えば、Chef Solo＋Knife Solo で行っていたようなシンプルな作業環境（作業用マシン1つあれば十分）でプロビジョニングが行えるようになります。

Chef ProvisioningはChef社が公式に開発しているもので、Chef Zero（作業マシン上で実行する度に自動的に起動する簡易Chef Server）を利用しています。
そしてdriverを切り替えることにより、ssh経由でのプロビジョニング以外に、AWSやDockerなどクラウド環境の構築も行えたりします。
ただ、従来Chef Soloを利用してた人やまだ触ったことがない人からすると若干敷居が高い面もあります。

そこでそのChef Provisioning自体は何も変えず、Chef Provisioningを使いやすくするための外部ツールとして開発したのが、ext-chef-provisioningです。


## Features
- Chef Solo＋Knife Soloのように利用できる
 - SSH接続してChefコードを流す（[chef-provisioning-ssh](https://github.com/chef/chef-provisioning-ssh)の利用を前提にしている）
 - 従来通りCookbookや run_list, attributesファイルを用意するだけ
 - Chef Provisioningの書き方や、詳細なknifeコマンドを覚えなくてもよい
 - site-cookbooksの実現（Chef Provisioning標準ではサポートしていない）

- 実務として構築作業をしやすくするためのファイル構成など整備
 - Chef標準と異なり、run_listとattributeの定義をそれぞれ1つのテキストファイルで管理
 - run_listとattributeは、`各環境別`、`各サーバー役割別`、`共通` に定義することができる
  - 例）「開発環境（environment）のwebサーバー（role）だけに適用するattribute」「本番環境の全てのサーバーに実行するrun_list」
 - 1回の実行で、複数のサーバーに対して連続してプロビジョニング可能
 - rootユーザーしかいない状態からでもノンストップでプロビジョニングができる
  - rootユーザーではadminアカウントを作るだけ、それ以後はadminアカウントで、といったことが可能

- 情報のすべてはファイルとして保存
 - そのままリポジトリすべてをgit管理できる
 - ログイン情報（パスワード）やdata_bag_keyといった秘匿情報はディレクトリを分けて.gitignoreできるような構成にしている


## Requirement
- chef-provisioning 
- chef-provisioning-ssh

## Install
1. ChefDKのダウンロード＆インストール  
https://downloads.chef.io/chef-dk/  
Chefを実行するマシン用のパッケージ（Mac,Linux,Windows等）をダウンロードしてインストールします

2. chef-provisioning-sshのインストール  
ChefDK同梱のgemでインストールします
        $ chef gem install chef-provisioning-ssh --no-ri --no-rdoc
3. このリポジトリのファイル一式ダウンロード

## Usage
基本的な使い方
--------------
ここでは `dev`というenvironmentの、`web`というroleをもつ、web01というホストに対しての例になります。

1. cookbooksディレクトリにCookbookを配置

2. ホスト情報を記述する
 - `settings/dev/web01.rb` をテキスト編集
  - `dev` や `web01.rb` という名称は自由に変更できます
  - `dev` はenvironment と名前を合わせた方がわかりやすいです
 - `@hosts` に、Provisioning実行するホスト情報（複数ホストの指定も可能）
 - `@environment`に、"dev"や"production"等、環境を示す文字列を定義
 - `@role`に、"web"や"manage"等、役割を示す文字列を定義

3. SSH接続するユーザーを記述する
 - `settings/dev/_auth/auth.rb.default` を `settings/dev/_auth/auth.rb` に改名
 - `@init_user` には、OS初期ユーザー（root, ec2-user等）のSSH接続可能なユーザー情報を記述
 - `@admin_user` には、その後の構築を実行するSSH接続可能なユーザー情報を記述
 - ※このディレクトリはgitignoreしているので、SSH接続に必要なパスワードも書いてよい
 
4. run_listsを記述する
 - `settings/run_list.rb` をテキスト編集する
 - `@init_run_list` には、OS初期ユーザーで実行するrun_listを記述（構築用ユーザー作成など）
 - `@run_list` には、サーバーのProvisioningをするrun_listを記述
 - `common` は、全てのroleで実行するrun_list
 - `web` は、role固有のrun_listで、`common`の後に実行される
 - `default`は、全てのenvironmentで実行するrun_list
 - `dev`は、environment固有のrun_listで、`default`の後に実行される

5. attributesを記述する
 - `settings/attributes_list.rb` をテキスト編集する
 - `common` は、全てのroleで共有するattribute
 - `web` は、role固有のattributeで、`common`の定義より優先される
 - `default`は、全てのenvironmentで共有するattribute
 - `dev`は、environment固有のattributeで、`default`の定義より優先される

6. chef-provisioningを実行

        cd settings/dev
        chef-client web01.rb -z

site-cookbooksでcookbookの内容上書き
--------------
例えばCookbookをChef Supermarketから取得したけど、どうしてもCookbookの中身の一部を書き換えたい場合、
site-cookbooksディレクトリに 上書きしたいファイルを配置すれば、そちらのファイルが優先されます

secretなdata_bagを利用する
--------------
- data_bag_keyを配置する
 - `settings/dev/data_bags/_key/data_bag_key.default` を `settings/dev/data_bags/_key/data_bag_key` に改名
 - data_bag_keyを作成して、上記ファイルに保存する
 - ※ このディレクトリもgitignoreしています

- 暗号化されたファイルを作成

        cd settings/dev
        knife data bag create hoge fuga.json --secret-file data_bags/_key/data_bag_key

- 暗号化されたファイルを編集

        cd settings/dev
        knife data bag edit hoge fuga.json

## example
run_list.rb
-----------
    @init_run_list = [
      "recipe[users]"
    ]

    @run_list = {
      "common" => {
        "default" => [
          "recipe[git]"
        ],

        "dev" => [
        ],
      },

      "web" => {
        "default" => [
          "recipe[nginx]"
        ],

        "dev" => [
        ],
      },
    }


attributes_list.rb
---------
    @attributes_list = {
      "common" => {
        "default" => {
        },

        "dev" => {
        },
      },

      "web" => {
        "default" => {
          "nginx" => {
            "port" => 80,
          },
        },

        "dev" => {
          "nginx" => {
            "worker_processes" => 1,
          },
        }
      }
    }


## License
[Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

Copyright (c) 2016 DWANGO Co., Ltd. All Rights Reserved.
