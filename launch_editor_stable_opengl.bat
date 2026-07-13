@echo off
setlocal
title CinnaCupQuest Safe OpenGL Editor Launcher
set "GODOT_EXE=D:\Godot\Godot_v4.3-stable_win64_console.exe"
set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "LOG_DIR=%PROJECT_DIR%\.godot-user"
set "LOG_FILE=%LOG_DIR%\editor_stable_opengl.log"
set "CONSOLE_LOG=%LOG_DIR%\editor_stable_opengl_console.log"
set "ARG_FILE=%LOG_DIR%\editor_stable_opengl_args.txt"
set "USER_DATA=%APPDATA%\Godot\app_userdata\Cinna Cup Quest"
set "CACHE_STAMP=%RANDOM%%RANDOM%"
set "RENDERING_DRIVER=opengl3"

if not exist "%GODOT_EXE%" (
  echo Godot executable not found: %GODOT_EXE%
  pause
  exit /b 1
)

if not exist "%LOG_DIR%" (
  mkdir "%LOG_DIR%"
)

if exist "%USER_DATA%\vulkan" (
  ren "%USER_DATA%\vulkan" "vulkan.disabled_%CACHE_STAMP%"
)

if exist "%USER_DATA%\shader_cache" (
  ren "%USER_DATA%\shader_cache" "shader_cache.disabled_%CACHE_STAMP%"
)

if exist "%PROJECT_DIR%\.godot\shader_cache" (
  ren "%PROJECT_DIR%\.godot\shader_cache" "shader_cache.disabled_%CACHE_STAMP%"
)

(
  echo Launcher=%~f0
  echo StartedAt=%DATE% %TIME%
  echo Godot=%GODOT_EXE%
  echo Project=%PROJECT_DIR%
  echo RenderingDriver=%RENDERING_DRIVER%
  echo RenderingMethod=gl_compatibility
  echo RenderThread=safe
  echo LogFile=%LOG_FILE%
  echo ConsoleLog=%CONSOLE_LOG%
  echo SafeEntry=Use this launcher or the desktop CinnaCupQuest editor shortcut, not the raw Godot GUI exe.
) > "%ARG_FILE%"

"%GODOT_EXE%" --disable-crash-handler --display-driver windows --rendering-driver %RENDERING_DRIVER% --rendering-method gl_compatibility --render-thread safe --single-window --max-fps 60 --log-file "%LOG_FILE%" --editor --path "%PROJECT_DIR%" > "%CONSOLE_LOG%" 2>&1
>> "%ARG_FILE%" echo ExitCode=%ERRORLEVEL%
if not "%ERRORLEVEL%"=="0" (
  echo.
  echo CinnaCupQuest editor failed to start. See:
  echo %CONSOLE_LOG%
  echo %LOG_FILE%
  pause
)
