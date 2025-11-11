-- ================================================================
-- DEPLOYMENT SCRIPT: estacionamiento_exclusivo
-- SPs Faltantes: 1
-- Fecha: 2025-11-11
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: estacionamiento_exclusivo
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: estacionamiento_exclusivo - 1 SPs'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;


-- [1/1] sp_chgpass_historial - 1 usos (⚪ BAJA)
\echo 'Creando: sp_chgpass_historial...'
\i ../generated/sp_chgpass_historial.sql
\echo '   ✓ OK'

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO: 1 SPs creados'
\echo '=================================================='
\echo ''
