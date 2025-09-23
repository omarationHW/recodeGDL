@echo off
echo ============================================
echo INSTALACION DE STORED PROCEDURES DEPENDENCIAS
echo ============================================
echo.
echo Instalando SPs para el modulo de Dependencias...
echo.

REM Configuracion de la base de datos
set DB_HOST=192.168.6.146
set DB_PORT=5432
set DB_NAME=padron_licencias
set DB_USER=postgres

echo Conectando a PostgreSQL en %DB_HOST%:%DB_PORT%
echo Base de datos: %DB_NAME%
echo.

REM Ejecutar el archivo SQL
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f "SP_DEPENDENCIAS_PROCEDURES.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo   INSTALACION COMPLETADA EXITOSAMENTE
    echo ============================================
    echo.
    echo Los siguientes SPs han sido instalados:
    echo - SP_DEPENDENCIAS_LIST
    echo - SP_DEPENDENCIAS_CREATE
    echo - SP_DEPENDENCIAS_UPDATE
    echo - SP_DEPENDENCIAS_DELETE
    echo.
) else (
    echo.
    echo ============================================
    echo        ERROR EN LA INSTALACION
    echo ============================================
    echo.
    echo Revisar los mensajes de error anteriores.
    echo.
)

pause