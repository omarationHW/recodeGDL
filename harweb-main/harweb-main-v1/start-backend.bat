@echo off
echo ========================================
echo  Iniciando Backend PHP - Puerto 8000
echo ========================================
echo.

cd /d "%~dp0backend-laravel\public"

echo Backend corriendo en: http://localhost:8000
echo API Endpoint: http://localhost:8000/api/generic
echo Presiona Ctrl+C para detener el servidor
echo.

php -S localhost:8000
