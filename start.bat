@echo off
title TeleBridge Bot
color 0a

echo Starting TeleBridge Bot...
echo.

:start
call npm run telebridge
timeout /t 5
goto start