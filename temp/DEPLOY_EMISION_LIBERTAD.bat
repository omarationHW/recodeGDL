@echo off
echo ========================================
echo   DEPLOY: EmisionLibertad SPs
echo ========================================
echo.
echo Este script desplegara los Stored Procedures
echo corregidos para el modulo EmisionLibertad:
echo.
echo   Base padron_licencias:
echo   - sp_get_recaudadoras
echo   - sp_get_mercados_by_recaudadora
echo.
echo   Base mercados:
echo   - generar_emision_libertad
echo   - exportar_emision_libertad
echo   - get_emision_libertad_detalle
echo.
echo ========================================
echo.
pause

c:\xampp\php\php.exe temp/deploy_emision_libertad_fix.php

echo.
echo ========================================
echo   Despliegue completado
echo ========================================
echo.
pause
