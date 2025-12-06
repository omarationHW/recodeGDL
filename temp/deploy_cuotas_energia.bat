@echo off
REM Script para desplegar Stored Procedures de Cuotas Energía
REM Requiere psql instalado y en PATH

echo ================================================
echo DEPLOY: Stored Procedures Cuotas Energia
echo ================================================
echo.
echo Servidor: 192.168.6.146:5432
echo Base de datos: mercados
echo Usuario: refact
echo.

set PGHOST=192.168.6.146
set PGPORT=5432
set PGDATABASE=mercados
set PGUSER=refact
set PGPASSWORD=FF)-BQk2

echo Desplegando stored procedures...
echo.

psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f 00_deploy_all_cuotas_energia.sql

echo.
echo ================================================
echo Deploy completado
echo ================================================
echo.
echo Verificando stored procedures creados...
echo.

echo SELECT p.proname, pg_get_function_arguments(p.oid) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.proname LIKE 'sp_%%cuota%%energia%%'; > verify.sql

psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f verify.sql

del verify.sql

echo.
pause
