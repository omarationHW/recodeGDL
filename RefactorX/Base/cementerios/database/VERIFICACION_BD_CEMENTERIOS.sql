-- ========================================================
-- VERIFICACIÓN COMPLETA DE BASE DE DATOS - CEMENTERIOS
-- ========================================================
-- Este script verifica que todos los componentes de BD estén correctamente instalados
-- Ejecutar en PostgreSQL con: psql -h 192.168.6.146 -U refact -d padron_licencias -f VERIFICACION_BD_CEMENTERIOS.sql

\echo '========================================='
\echo 'VERIFICACIÓN DE BASE DE DATOS - CEMENTERIOS'
\echo '========================================='
\echo ''

-- ========================================
-- 1. VERIFICAR TABLAS
-- ========================================
\echo '1. VERIFICANDO TABLAS PRINCIPALES...'
\echo ''

SELECT
    'TABLAS' as tipo,
    schemaname as esquema,
    tablename as nombre,
    CASE
        WHEN tablename LIKE '%cementerio%' OR
             tablename LIKE '%difunto%' OR
             tablename LIKE '%lote%' OR
             tablename LIKE '%fosa%' OR
             tablename LIKE '%servicio%' OR
             tablename LIKE '%pago%' THEN '✓ ENCONTRADA'
        ELSE '✗ NO RELACIONADA'
    END as estado
FROM pg_tables
WHERE schemaname = 'public'
  AND (tablename LIKE '%cementerio%'
    OR tablename LIKE '%difunto%'
    OR tablename LIKE '%lote%'
    OR tablename LIKE '%fosa%'
    OR tablename LIKE '%servicio%'
    OR tablename LIKE '%pago%')
ORDER BY tablename;

\echo ''
\echo '========================================='

-- ========================================
-- 2. VERIFICAR STORED PROCEDURES
-- ========================================
\echo '2. VERIFICANDO STORED PROCEDURES...'
\echo ''

SELECT
    'SP' as tipo,
    n.nspname as esquema,
    p.proname as nombre,
    pg_get_function_identity_arguments(p.oid) as parametros,
    CASE
        WHEN p.proname LIKE 'sp_cementerios%' THEN '✓ NOMENCLATURA CORRECTA'
        WHEN p.proname LIKE 'sp_cem_%' THEN '✓ NOMENCLATURA CORRECTA'
        WHEN p.proname LIKE 'sp_%' AND (
            p.proname LIKE '%difunto%' OR
            p.proname LIKE '%lote%' OR
            p.proname LIKE '%cementerio%'
        ) THEN '⚠ VERIFICAR NOMENCLATURA'
        ELSE '✗ NOMENCLATURA INCORRECTA'
    END as estado
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND (p.proname LIKE '%cementerio%'
    OR p.proname LIKE '%difunto%'
    OR p.proname LIKE '%cem_%'
    OR p.proname LIKE 'sp_cem%')
ORDER BY p.proname;

\echo ''
\echo '========================================='

-- ========================================
-- 3. CONTAR STORED PROCEDURES POR TIPO
-- ========================================
\echo '3. CONTEO DE STORED PROCEDURES...'
\echo ''

SELECT
    CASE
        WHEN proname LIKE 'sp_cementerios_difunto%' THEN 'DIFUNTOS'
        WHEN proname LIKE 'sp_cementerios_cementerio%' THEN 'CEMENTERIOS'
        WHEN proname LIKE 'sp_cementerios_lote%' THEN 'LOTES'
        WHEN proname LIKE 'sp_cementerios_servicio%' THEN 'SERVICIOS'
        WHEN proname LIKE 'sp_cementerios_pago%' THEN 'PAGOS'
        WHEN proname LIKE 'sp_cementerios_renovacion%' THEN 'RENOVACIONES'
        WHEN proname LIKE 'sp_cementerios_reporte%' THEN 'REPORTES'
        WHEN proname LIKE 'sp_cementerios_buscar%' THEN 'BUSQUEDA'
        WHEN proname LIKE 'sp_cementerios_dashboard%' THEN 'DASHBOARD'
        WHEN proname LIKE 'sp_cementerios_%' THEN 'OTROS'
        WHEN proname LIKE 'sp_cem_%' THEN 'CEM_PREFIJO'
        ELSE 'DESCONOCIDO'
    END as categoria,
    COUNT(*) as cantidad
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND (p.proname LIKE 'sp_cementerios%' OR p.proname LIKE 'sp_cem%')
GROUP BY categoria
ORDER BY cantidad DESC;

\echo ''
\echo '========================================='

-- ========================================
-- 4. VERIFICAR SPs CRÍTICOS (deben existir)
-- ========================================
\echo '4. VERIFICANDO SPs CRÍTICOS...'
\echo ''

WITH sps_criticos AS (
    SELECT unnest(ARRAY[
        'sp_cementerios_difuntos_list',
        'sp_cementerios_difunto_get',
        'sp_cementerios_difunto_create',
        'sp_cementerios_cementerios_list',
        'sp_cementerios_lotes_list',
        'sp_cementerios_servicios_list',
        'sp_cementerios_pagos_list',
        'sp_cementerios_buscar_difunto',
        'sp_cementerios_estadisticas'
    ]) as sp_nombre
)
SELECT
    sc.sp_nombre as sp_esperado,
    CASE
        WHEN p.proname IS NOT NULL THEN '✓ EXISTE'
        ELSE '✗ NO ENCONTRADO'
    END as estado,
    CASE
        WHEN p.proname IS NOT NULL THEN pg_get_function_identity_arguments(p.oid)
        ELSE 'N/A'
    END as parametros
FROM sps_criticos sc
LEFT JOIN pg_proc p ON LOWER(p.proname) = LOWER(sc.sp_nombre)
LEFT JOIN pg_namespace n ON p.pronamespace = n.oid AND n.nspname = 'public'
ORDER BY sc.sp_nombre;

\echo ''
\echo '========================================='

-- ========================================
-- 5. VERIFICAR SECUENCIAS
-- ========================================
\echo '5. VERIFICANDO SECUENCIAS...'
\echo ''

SELECT
    'SECUENCIA' as tipo,
    schemaname as esquema,
    sequencename as nombre,
    '✓ ENCONTRADA' as estado
FROM pg_sequences
WHERE schemaname = 'public'
  AND (sequencename LIKE '%cementerio%'
    OR sequencename LIKE '%difunto%'
    OR sequencename LIKE '%lote%')
ORDER BY sequencename;

\echo ''
\echo '========================================='

-- ========================================
-- 6. VERIFICAR VISTAS
-- ========================================
\echo '6. VERIFICANDO VISTAS...'
\echo ''

SELECT
    'VISTA' as tipo,
    schemaname as esquema,
    viewname as nombre,
    '✓ ENCONTRADA' as estado
FROM pg_views
WHERE schemaname = 'public'
  AND (viewname LIKE '%cementerio%'
    OR viewname LIKE '%difunto%'
    OR viewname LIKE '%lote%')
ORDER BY viewname;

\echo ''
\echo '========================================='

-- ========================================
-- 7. RESUMEN FINAL
-- ========================================
\echo '7. RESUMEN FINAL DE VERIFICACIÓN...'
\echo ''

SELECT
    'RESUMEN' as seccion,
    'Tablas Cementerios' as componente,
    COUNT(*) as cantidad
FROM pg_tables
WHERE schemaname = 'public'
  AND (tablename LIKE '%cementerio%' OR tablename LIKE '%difunto%' OR tablename LIKE '%lote%')
UNION ALL
SELECT
    'RESUMEN',
    'Stored Procedures',
    COUNT(*)
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND (p.proname LIKE 'sp_cementerios%' OR p.proname LIKE 'sp_cem%')
UNION ALL
SELECT
    'RESUMEN',
    'Secuencias',
    COUNT(*)
FROM pg_sequences
WHERE schemaname = 'public'
  AND (sequencename LIKE '%cementerio%' OR sequencename LIKE '%difunto%')
UNION ALL
SELECT
    'RESUMEN',
    'Vistas',
    COUNT(*)
FROM pg_views
WHERE schemaname = 'public'
  AND (viewname LIKE '%cementerio%' OR viewname LIKE '%difunto%');

\echo ''
\echo '========================================='
\echo 'VERIFICACIÓN COMPLETADA'
\echo '========================================='
\echo ''
\echo 'INSTRUCCIONES:'
\echo '1. Revisar que todas las tablas principales existan'
\echo '2. Verificar que los 9 SPs CRÍTICOS estén instalados'
\echo '3. Confirmar que el total de SPs sea cercano a 93'
\echo '4. Si faltan componentes, ejecutar scripts de instalación'
\echo ''
