# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# 定数（初期化フラグ　true:初期化（Truncate）後にインポート開始）
truncate_flg = true

# メソッド
def truncate_table(table_name)
  query = "TRUNCATE TABLE #{table_name.to_s}"
  puts query.to_s
  ActiveRecord::Base.connection.execute query.to_s
end

# パッケージ制御ファイルテーブル
table_name = 'app_envs'
truncate_table(table_name) if truncate_flg
puts "CREATE DATA #{table_name}"
AppEnv.create(:id => 1, :key => 'FILE_LIFE_PERIOD', :value => '3600', :note => '1時間', :category => 3)
AppEnv.create(:id => 2, :key => 'FILE_LIFE_PERIOD', :value => '43200', :note => '12時間', :category => 3)
AppEnv.create(:id => 3, :key => 'FILE_LIFE_PERIOD', :value => '86400', :note => '1日', :category => 3)
AppEnv.create(:id => 4, :key => 'FILE_LIFE_PERIOD', :value => '259200', :note => '3日', :category => 3)
AppEnv.create(:id => 5, :key => 'FILE_LIFE_PERIOD', :value => '604800', :note => '7日', :category => 3)
AppEnv.create(:id => 6, :key => 'FILE_LIFE_PERIOD_DEF', :value => '3', :category => 3)
AppEnv.create(:id => 7, :key => 'RECEIVERS_LIMIT', :value => '5', :category => 3)
AppEnv.create(:id => 8, :key => 'FILE_SEND_LIMIT', :value => '5', :category => 3)
AppEnv.create(:id => 9, :key => 'FILE_SIZE_LIMIT', :value => '50', :category => 3)
AppEnv.create(:id => 10, :key => 'FILE_TOTAL_SIZE_LIMIT', :value => '100', :category => 3)
AppEnv.create(:id => 11, :key => 'MESSAGE_LIMIT', :value => '400', :category => 3)
AppEnv.create(:id => 12, :key => 'PW_LENGTH_MIN', :value => '4', :category => 3)
AppEnv.create(:id => 13, :key => 'PW_LENGTH_MAX', :value => '8', :category => 3)
AppEnv.create(:id => 14, :key => 'FILE_LIFE_PERIOD', :value => '3600', :note => '1時間', :category => 2)
AppEnv.create(:id => 15, :key => 'FILE_LIFE_PERIOD', :value => '43200', :note => '12時間', :category => 2)
AppEnv.create(:id => 16, :key => 'FILE_LIFE_PERIOD', :value => '86400', :note => '1日', :category => 2)
AppEnv.create(:id => 17, :key => 'FILE_LIFE_PERIOD', :value => '259200', :note => '3日', :category => 2)
AppEnv.create(:id => 18, :key => 'FILE_LIFE_PERIOD', :value => '604800', :note => '7日', :category => 2)
AppEnv.create(:id => 19, :key => 'FILE_LIFE_PERIOD_DEF', :value => '16', :category => 2)
AppEnv.create(:id => 20, :key => 'RECEIVERS_LIMIT', :value => '5', :category => 2)
AppEnv.create(:id => 21, :key => 'FILE_SEND_LIMIT', :value => '5', :category => 2)
AppEnv.create(:id => 22, :key => 'FILE_SIZE_LIMIT', :value => '50', :category => 2)
AppEnv.create(:id => 23, :key => 'FILE_TOTAL_SIZE_LIMIT', :value => '100', :category => 2)
AppEnv.create(:id => 24, :key => 'MESSAGE_LIMIT', :value => '400', :category => 2)
AppEnv.create(:id => 25, :key => 'PW_LENGTH_MIN', :value => '4', :category => 2)
AppEnv.create(:id => 26, :key => 'PW_LENGTH_MAX', :value => '8', :category => 2)
AppEnv.create(:id => 27, :key => 'REQUEST_PERIOD', :value => '604800', :note => '7日', :category => 0)
AppEnv.create(:id => 28, :key => 'PASSWORD_AUTOMATION', :value => '0', :category => 0)
AppEnv.create(:id => 29, :key => 'ENABLE_SSL', :value => '0', :category => 0)
AppEnv.create(:id => 30, :key => 'VIRUS_CHECK', :value => '1', :category => 0)
AppEnv.create(:id => 31, :key => 'VIRUS_CHECK_NOTICE', :value => '0', :category => 0)
