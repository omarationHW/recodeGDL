-- ========================================
-- SCRIPT DE VERIFICACIÓN DE SPs CEMENTERIOS
-- ========================================
-- Ejecutar en PostgreSQL para verificar si los SPs están instalados

\echo '=========================================='
\echo 'VERIFICACIÓN DE STORED PROCEDURES - CEMENTERIOS'
\echo '=========================================='
\echo ''

-- 1. Contar SPs de Cementerios instalados
\echo '1. Total de SPs de Cementerios:'
SELECT COUNT(*) as total_sps_cementerios
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
    AND routine_schema = 'public'
    AND (
        routine_name LIKE 'sp_cem_%'
        OR routine_name LIKE 'sp_cementerios_%'
    );

\echo ''
\echo '2. Lista de SPs instalados:'
SELECT
    routine_name as nombre_sp,
    routine_schema as esquema,
    specific_name as nombre_especifico
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
    AND routine_schema = 'public'
    AND (
        routine_name LIKE 'sp_cem_%'
        OR routine_name LIKE 'sp_cementerios_%'
    )
ORDER BY routine_name;

\echo ''
\echo '3. SPs CRÍTICOS requeridos por componentes Vue:'

-- Lista de SPs que DEBEN existir
WITH sps_requeridos AS (
    SELECT unnest(ARRAY[
        'sp_cem_consultar_folio',
        'sp_cem_consultar_pagos_folio',
        'sp_cem_listar_cementerios',
        'sp_abcf_get_folio',
        'sp_abcf_update_folio',
        'sp_cem_consultar_guadalajara',
        'sp_cem_consultar_jardin',
        'sp_cem_consultar_sanandres',
        'sp_cem_listar_movimientos',
        'sp_cem_reporte_cuentas_cobrar',
        'sp_cem_reporte_bonificaciones',
        'sp_cem_reporte_titulos',
        'sp_validar_password_actual',
        'sp_cambiar_password',
        'sp_cem_estadisticas_adeudo'
    ]) AS sp_nombre
)
SELECT
    sr.sp_nombre,
    CASE
        WHEN r.routine_name IS NOT NULL THEN '✓ INSTALADO'
        ELSE '✗ FALTA'
    END AS estado
FROM sps_requeridos sr
LEFT JOIN information_schema.routines r
    ON r.routine_name = sr.sp_nombre
    AND r.routine_schema = 'public'
ORDER BY estado DESC, sr.sp_nombre;

\echo ''
\echo '4. Verificar tablas necesarias:'
SELECT
    table_name,
    table_schema
FROM information_schema.tables
WHERE (
    table_schema = 'public'
    OR table_schema = 'padron_licencias'
)
AND (
    table_name LIKE '%cementerio%'
    OR table_name LIKE '%rcm%'
    OR table_name LIKE '%folio%'
)
ORDER BY table_schema, table_name;

\echo ''
\echo '=========================================='
\echo 'RESUMEN:'
\echo '=========================================='
\echo 'Si faltan SPs, ejecutar archivos en orden:'
\echo '  01_SP_CEMENTERIOS_CORE_all_procedures.sql'
\echo '  02_SP_CEMENTERIOS_GESTION_all_procedures.sql'
\echo '  03_SP_CEMENTERIOS_ABC_all_procedures.sql'
\echo '  ... (continuar con todos)'
\echo '=========================================='
