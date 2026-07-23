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

bot.command(:lock) do |event|
  event.respond(' 持ち主からの命令を受信しました。パソコンの画面をロックします！')
  system("rundll32.exe user32.dll,LockWorkStation")
end

bot.ready do
  Thread.new do
    loop do
      image_path = 'images/alert.jpg'

      if File.exist?(image_path)
        puts " 画像を検知しました。Discordに送信します..."
        

        bot.send_file(CHANNEL_ID, File.open(image_path), caption: '【警告】カメラが動作を検知しました！ロックしますか？ (/lock)')
        
        File.delete(image_path)
        puts "画像を送信し、元のファイルを削除しました。"
      end
      
      sleep 1
    end
  end
end

puts " 監視Botを起動しています..."
bot.run