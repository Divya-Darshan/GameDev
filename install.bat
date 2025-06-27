@echo off
set APK_PATH= .\app\app.apk
set PACKAGE_NAME= com.darshni.game

adb install -r %APK_PATH%
if %ERRORLEVEL% EQU 0 (
    adb shell monkey -p %PACKAGE_NAME% -c android.intent.category.LAUNCHER 1
) else (
    echo Installation failed.
)
pause
