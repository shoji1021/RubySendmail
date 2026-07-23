require 'discordrb'
require 'dotenv'

Dotenv.load

TOKEN = ENV['DISCORD_BOT_TOKEN']
CHANNEL_ID = ENV['DISCORD_CHANNEL_ID'].to_i

bot = Discordrb::Commands::CommandBot.new(
  token: TOKEN,
  prefix: '/'
)


bot.button(custom_id: 'lock_yes') do |event|
  event.update_message(content: '画面を即時ロックしました。', components: nil)
  system("rundll32.exe user32.dll,LockWorkStation")
  puts "ボタン操作によりPCをロックしました。"
end


bot.button(custom_id: 'sound_alarm') do |event|
  event.update_message(content: '警報（警告音）を発令しました。', components: nil)

  system('powershell -c "1..10 | ForEach-Object { [console]::beep(2000, 150); Start-Sleep -Milliseconds 80 }"')
  system('powershell -c "1..10 | ForEach-Object { [console]::beep(2000, 150); Start-Sleep -Milliseconds 80 }"')
  system('powershell -c "1..10 | ForEach-Object { [console]::beep(2000, 150); Start-Sleep -Milliseconds 80 }"')
  system('powershell -c "1..10 | ForEach-Object { [console]::beep(2000, 150); Start-Sleep -Milliseconds 80 }"')
  puts "ボタン操作により警報を鳴らしました。"
end


bot.button(custom_id: 'lock_no') do |event|
  event.update_message(content: '処理をキャンセルしました。', components: nil)
  puts "処理をキャンセルしました。"
end


bot.ready do
  Thread.new do
    loop do
      image_path = 'images/alert.jpg'

      if File.exist?(image_path)
        puts "画像を検知しました。Discordに送信します..."
        
        # 1. まず画像を送信
        bot.send_file(CHANNEL_ID, File.open(image_path))
        
        # 2. ボタン（View）を作成
        view = Discordrb::Webhooks::View.new
        view.row do |r|
          # style: 4 = 赤（Danger）、1 = 青（Primary）、2 = 灰（Secondary）
          r.button(custom_id: 'lock_yes', label: 'ロックする', style: 4)
          r.button(custom_id: 'sound_alarm', label: '警報を鳴らす', style: 1)
          r.button(custom_id: 'lock_no', label: '無視する', style: 2)
        end
        
        # 3. ボタン付きの警告メッセージを送信
        bot.send_message(CHANNEL_ID, '【警告】カメラが動作を検知しました。対応を選択してください。', false, nil, nil, nil, nil, view)
        
        File.delete(image_path)
        puts "画像を送信し、元のファイルを削除しました。"
      end
      
      sleep 1
    end
  end
end

puts "監視Botを起動しています..."
bot.run