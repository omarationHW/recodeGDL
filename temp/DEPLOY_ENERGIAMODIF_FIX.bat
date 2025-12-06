@echo off
echo ============================================================
echo DESPLIEGUE DE SPs CORREGIDOS PARA EnergiaModif
echo ============================================================
echo.
echo Este script desplegará los 2 SPs corregidos:
echo   1. sp_energia_modif_buscar
echo   2. sp_energia_modif_modificar
echo.
echo Problema solucionado: Referencias cross-database
echo.
pause

"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d padron_licencias -f "C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\deploy_energiamodif_sps_corregidos.sql"

echo.
echo ============================================================
echo DESPLIEGUE COMPLETADO
echo ============================================================
pause
