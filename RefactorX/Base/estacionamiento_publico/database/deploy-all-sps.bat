@echo off
setlocal EnableDelayedExpansion

set PGHOST=192.168.6.146
set PGPORT=5432
set PGDATABASE=padron_licencias
set PGUSER=refact
set PGPASSWORD=FF)-BQk2

set DATABASE_DIR=database\database
set LOG_FILE=deployment.log
set REPORT_FILE=sp-deployment-report.json

echo Iniciando despliegue de SPs... > %LOG_FILE%
echo { > %REPORT_FILE%
echo   "fecha": "%date%", >> %REPORT_FILE%
echo   "hora": "%time%", >> %REPORT_FILE%
echo   "detalle": { >> %REPORT_FILE%

set /a TOTAL=0
set /a EXITOSOS=0
set /a ERRORES=0

for %%F in (%DATABASE_DIR%\*.sql) do (
    set /a TOTAL+=1
    echo. >> %LOG_FILE%
    echo [!TOTAL!] Procesando: %%~nxF >> %LOG_FILE%
    echo [!TOTAL!] Procesando: %%~nxF

    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%%F" >> %LOG_FILE% 2>&1

    if !ERRORLEVEL! EQU 0 (
        set /a EXITOSOS+=1
        echo     EXITOSO >> %LOG_FILE%
        echo     EXITOSO
    ) else (
        set /a ERRORES+=1
        echo     ERROR >> %LOG_FILE%
        echo     ERROR
    )
)

echo. >> %LOG_FILE%
echo ============================================ >> %LOG_FILE%
echo REPORTE FINAL >> %LOG_FILE%
echo ============================================ >> %LOG_FILE%
echo Total archivos: !TOTAL! >> %LOG_FILE%
echo Exitosos: !EXITOSOS! >> %LOG_FILE%
echo Errores: !ERRORES! >> %LOG_FILE%

echo   }, >> %REPORT_FILE%
echo   "total_archivos": !TOTAL!, >> %REPORT_FILE%
echo   "sps_exitosos": !EXITOSOS!, >> %REPORT_FILE%
echo   "sps_con_errores": !ERRORES! >> %REPORT_FILE%
echo } >> %REPORT_FILE%

echo.
echo ============================================
echo REPORTE FINAL
echo ============================================
echo Total archivos: !TOTAL!
echo Exitosos: !EXITOSOS!
echo Errores: !ERRORES!
echo.
echo Log guardado en: %LOG_FILE%
echo Reporte guardado en: %REPORT_FILE%

endlocal
