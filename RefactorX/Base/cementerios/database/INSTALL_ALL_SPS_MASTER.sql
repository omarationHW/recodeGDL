-- =====================================================
-- SCRIPT MAESTRO DE INSTALACIÓN - MÓDULO CEMENTERIOS
-- =====================================================
-- Este script instala TODOS los Stored Procedures necesarios
-- para el funcionamiento completo del módulo de Cementerios
--
-- IMPORTANTE:
-- - Ejecutar en PostgreSQL
-- - Esquema: public
-- - Usuario: con permisos de creación de funciones
--
-- USO:
--   psql -U postgres -d nombre_base_datos -f INSTALL_ALL_SPS_MASTER.sql
--
-- =====================================================

\echo ''
\echo '=========================================='
\echo 'INSTALACIÓN MÓDULO CEMENTERIOS'
\echo '=========================================='
\echo 'Instalando Stored Procedures en PostgreSQL...'
\echo ''

-- Configuración inicial
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

\echo '1/3 - SPs CORE (Funciones principales)...'
\i ok/01_SP_CEMENTERIOS_CORE_all_procedures.sql

\echo '2/3 - SPs GESTIÓN (Módulos de gestión)...'
\i ok/02_SP_CEMENTERIOS_GESTION_all_procedures.sql

\echo '3/3 - SPs ABC (Alta, Baja, Cambio)...'
\i ok/03_SP_CEMENTERIOS_ABC_all_procedures.sql

\echo ''
\echo '=========================================='
\echo 'VERIFICACIÓN DE INSTALACIÓN'
\echo '=========================================='

-- Contar SPs instalados
SELECT COUNT(*) as total_sps_cementerios
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
    AND routine_schema = 'public'
    AND (
        routine_name LIKE 'sp_cem_%'
        OR routine_name LIKE 'sp_cementerios_%'
    );

\echo ''
\echo 'SPs CRÍTICOS instalados:'

-- Verificar SPs críticos
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'sp_cem_consultar_folio' AND routine_schema = 'public')
        THEN '✓ sp_cem_consultar_folio'
        ELSE '✗ FALTA: sp_cem_consultar_folio'
    END as sp_1
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'sp_cem_consultar_pagos_folio' AND routine_schema = 'public')
        THEN '✓ sp_cem_consultar_pagos_folio'
        ELSE '✗ FALTA: sp_cem_consultar_pagos_folio'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'sp_cem_listar_cementerios' AND routine_schema = 'public')
        THEN '✓ sp_cem_listar_cementerios'
        ELSE '✗ FALTA: sp_cem_listar_cementerios'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'sp_abcf_get_folio' AND routine_schema = 'public')
        THEN '✓ sp_abcf_get_folio'
        ELSE '✗ FALTA: sp_abcf_get_folio'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'sp_abcf_update_folio' AND routine_schema = 'public')
        THEN '✓ sp_abcf_update_folio'
        ELSE '✗ FALTA: sp_abcf_update_folio'
    END;

\echo ''
\echo '=========================================='
\echo 'INSTALACIÓN COMPLETADA'
\echo '=========================================='
\echo 'Siguiente paso: Verificar componentes Vue'
\echo '=========================================='
