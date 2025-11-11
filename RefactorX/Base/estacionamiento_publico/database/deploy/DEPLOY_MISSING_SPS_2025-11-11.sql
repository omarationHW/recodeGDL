-- ================================================================
-- DEPLOYMENT SCRIPT: estacionamiento_publico
-- SPs Faltantes: 4
-- Fecha: 2025-11-11
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: estacionamiento_publico
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: estacionamiento_publico - 4 SPs'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;


-- [1/4] spubreports - 2 usos (🟡 MEDIA)
\echo 'Creando: spubreports...'
\i ../generated/spubreports.sql
\echo '   ✓ OK'

-- [2/4] sp_sfrm_baja_pub - 1 usos (⚪ BAJA)
\echo 'Creando: sp_sfrm_baja_pub...'
\i ../generated/sp_sfrm_baja_pub.sql
\echo '   ✓ OK'

-- [3/4] spget_lic_grales - 1 usos (⚪ BAJA)
\echo 'Creando: spget_lic_grales...'
\i ../generated/spget_lic_grales.sql
\echo '   ✓ OK'

-- [4/4] spget_lic_detalles - 1 usos (⚪ BAJA)
\echo 'Creando: spget_lic_detalles...'
\i ../generated/spget_lic_detalles.sql
\echo '   ✓ OK'

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO: 4 SPs creados'
\echo '=================================================='
\echo ''
