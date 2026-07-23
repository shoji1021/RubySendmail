require 'uri'
require 'net/http'

# あなたのWebhook URLを貼り付けてください
webhook_url = 'https://discord.com/api/webhooks/1526106783972724756/8Yz3baneSeriioy9mj31ZVCIQ7aSJBRmSItKK7VYcgurSDsZqjNkzUILvPDtyoMu-wwX'

uri = URI.parse(webhook_url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

# 送信する画像ファイルの名前（同じフォルダにある前提）
image_path = 'images/test.jpg'

# ファイルが存在するかチェック
unless File.exist?(image_path)
  puts "エラー: #{image_path} が見つかりません。スクリプトと同じフォルダに画像を置いてください。"
  exit
end

# 送信データ（リクエスト）の作成
request = Net::HTTP::Post.new(uri.request_uri)

# メッセージと画像ファイルをセットする（multipart/form-data形式）
form_data = [
  ['content', '【警告】カメラが動作を検知しました！画像を確認してください。'],
  ['file', File.open(image_path), { filename: File.basename(image_path) }]
]
request.set_form(form_data, 'multipart/form-data')

# いざ送信！
puts "画像とメッセージをDiscordへ送信中..."
response = http.request(request)

# 結果の確認
if response.code == '204' || response.code == '200'
  puts "成功しました！Discordに画像が届いているか確認してください。"
else
  puts "送信に失敗しました... (エラーコード: #{response.code})"
  puts response.body
end