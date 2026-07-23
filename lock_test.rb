puts "3秒後にWindowsの画面をロックします..."
sleep(3) # 3秒待機
system("rundll32.exe user32.dll,LockWorkStation")