@echo off
REM Script de prueba para Stored Procedures de Cuotas Energía
REM Ejecuta las pruebas directamente con psql

echo ======================================
echo PRUEBAS: Cuotas Energia Mantenimiento
echo ======================================
echo.

REM Configuración
set PGHOST=192.168.6.146
set PGPORT=5432
set PGDATABASE=mercados
set PGUSER=refact
set PGPASSWORD=FF)-BQk2

echo Conectando a %PGHOST%:%PGPORT%/%PGDATABASE%...
echo.

REM Crear archivo temporal con las pruebas
echo -- PRUEBA 1: Listar todas las cuotas > test_queries.sql
echo SELECT 'PRUEBA 1: Listar todas las cuotas' as prueba; >> test_queries.sql
echo SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL) LIMIT 5; >> test_queries.sql
echo. >> test_queries.sql

echo -- PRUEBA 2: Filtrar por año 2024 >> test_queries.sql
echo SELECT 'PRUEBA 2: Filtrar por año 2024' as prueba; >> test_queries.sql
echo SELECT * FROM public.sp_list_cuotas_energia(2024, NULL) LIMIT 3; >> test_queries.sql
echo. >> test_queries.sql

echo -- PRUEBA 3: Intentar insertar duplicado (debe fallar) >> test_queries.sql
echo SELECT 'PRUEBA 3: Intentar insertar duplicado' as prueba; >> test_queries.sql
echo SELECT * FROM public.sp_insert_cuota_energia( >> test_queries.sql
echo     (SELECT axo FROM public.ta_11_kilowhatts LIMIT 1), >> test_queries.sql
echo     (SELECT periodo FROM public.ta_11_kilowhatts LIMIT 1), >> test_queries.sql
echo     100.00, >> test_queries.sql
echo     1 >> test_queries.sql
echo ); >> test_queries.sql
echo. >> test_queries.sql

echo -- PRUEBA 4: Validación - importe negativo >> test_queries.sql
echo SELECT 'PRUEBA 4: Validación - importe negativo' as prueba; >> test_queries.sql
echo SELECT * FROM public.sp_insert_cuota_energia(2099, 1, -50.00, 1); >> test_queries.sql
echo. >> test_queries.sql

echo -- PRUEBA 5: Verificar SPs creados >> test_queries.sql
echo SELECT 'PRUEBA 5: Verificar SPs creados' as prueba; >> test_queries.sql
echo SELECT p.proname as nombre, pg_get_function_arguments(p.oid) as parametros >> test_queries.sql
echo FROM pg_proc p >> test_queries.sql
echo JOIN pg_namespace n ON p.pronamespace = n.oid >> test_queries.sql
echo WHERE n.nspname = 'public' >> test_queries.sql
echo AND p.proname IN ('sp_list_cuotas_energia', 'sp_insert_cuota_energia', 'sp_update_cuota_energia') >> test_queries.sql
echo ORDER BY p.proname; >> test_queries.sql

echo Ejecutando pruebas...
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f test_queries.sql

echo.
echo Pruebas completadas.
pause
