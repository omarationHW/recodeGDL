@echo off
echo ============================================================
echo DESPLIEGUE DE SPs CORREGIDOS - EnergiaModif
echo Servidor: 192.168.6.146:5432
echo Base de datos: padron_licencias
echo ============================================================
echo.

set PGPASSWORD=FF)-BQk2

"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h 192.168.6.146 -p 5432 -U refact -d padron_licencias -f "C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\deploy_energiamodif_sps_corregidos.sql"

set PGPASSWORD=

echo.
echo ============================================================
echo DESPLIEGUE COMPLETADO
echo ============================================================
pause
