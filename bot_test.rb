require 'discordrb'
require 'dotenv'

Dotenv.load

TOKEN = ENV['DISCORD_BOT_TOKEN']
CHANNEL_ID = ENV['DISCORD_CHANNEL_ID'].to_i

bot = Discordrb::Commands::CommandBot.new(
  token: TOKEN,
  prefix: '/'
)

bot.command(:ping) do |event|
  event.respond('pong! ')
end

bot.button(custom_id: 'lock_yes') do |event|

  event.update_message(content: ' 画面を即時ロックしました！', components: nil)
  system("rundll32.exe user32.dll,LockWorkStation")
  puts "ボタン操作によりPCをロックしました。"
end

bot.button(custom_id: 'lock_no') do |event|

  event.update_message(content: ' ロックをキャンセルしました。', components: nil)
  puts "ロックをキャンセルしました。"
end

bot.ready do
  Thread.new do
    loop do
      image_path = 'images/alert.jpg'

      if File.exist?(image_path)
        puts " 画像を検知しました。Discordに送信します..."
        
        # 1. まず画像を送信
        bot.send_file(CHANNEL_ID, File.open(image_path))
        
        # 2. ボタン（View）を作成
        view = Discordrb::Webhooks::View.new
        view.row do |r|
          
          r.button(custom_id: 'lock_yes', label: ' ロックする', style: 4)
          r.button(custom_id: 'lock_no', label: '無視する', style: 2)
        end
        

        bot.send_message(CHANNEL_ID, '【警告】カメラが動作を検知しました！PCをロックしますか？', false, nil, nil, nil, nil, view)
        
        File.delete(image_path)
        puts "画像を送信し、元のファイルを削除しました。"
      end
      
      sleep 1
    end
  end
end

puts " 監視Botを起動しています..."
bot.run