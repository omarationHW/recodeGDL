@echo off
echo ========================================
echo   COPIA DE TABLA: ta_11_cuo_locales
echo ========================================
echo.
echo Origen:  mercados.public.ta_11_cuo_locales
echo Destino: padron_licencias.comun.ta_11_cuo_locales
echo.
echo ========================================
echo.
pause

c:\xampp\php\php.exe temp/copiar_ta_11_cuo_locales.php

echo.
echo ========================================
echo   Proceso completado
echo ========================================
echo.
pause
