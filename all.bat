@echo off

:: RubyのBotを別ウィンドウで起動
echo Open Ruby
start ruby bot_test.rb

:: Pythonの動体検知を別ウィンドウで起動
echo Open Python
start python sendmail.py

echo.
echo 起動が完了しました！2つの黒い画面が立ち上がります。
echo システムを終了するときは、開いた黒い画面を「×」ボタンで閉じてください。
echo ==========================================
pause