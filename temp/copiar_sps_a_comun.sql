-- =====================================================
-- Copiar SPs de catastro_gdl a comun
-- Componente: catalogogirosfrm.vue
-- Fecha: 2025-11-05
-- =====================================================

-- Verificar si existen en catastro_gdl
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'catastro_gdl'
        AND p.proname LIKE 'sp_catalogogiros%'
    ) THEN
        RAISE NOTICE 'SPs encontrados en catastro_gdl - Procediendo a copiar...';
    ELSE
        RAISE NOTICE 'SPs NO encontrados en catastro_gdl - Usando archivo DEPLOY';
    END IF;
END $$;

-- Ejecutar el script DEPLOY_CATALOGOGIROS.sql directamente
\echo 'Ejecutando DEPLOY_CATALOGOGIROS.sql en esquema comun...'
\i RefactorX/Base/padron_licencias/database/ok/DEPLOY_CATALOGOGIROS.sql

\echo 'Proceso completado!'
