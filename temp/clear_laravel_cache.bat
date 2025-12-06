@echo off
echo Limpiando cache de Laravel...
echo.

cd /d "C:\guadalajara\code\recodeGDLCurrent\recodeGDL\RefactorX\BackEnd"

echo 1. Limpiando cache de aplicacion...
php artisan cache:clear

echo.
echo 2. Limpiando cache de configuracion...
php artisan config:clear

echo.
echo 3. Limpiando cache de rutas...
php artisan route:clear

echo.
echo 4. Limpiando cache de vistas...
php artisan view:clear

echo.
echo ✓ Cache de Laravel limpiado
echo.
echo Por favor reinicia el servidor de Laravel si esta corriendo
pause
