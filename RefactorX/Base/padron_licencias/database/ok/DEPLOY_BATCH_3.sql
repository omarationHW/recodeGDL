-- ============================================
-- DEPLOY CONSOLIDADO - BATCH 3
-- Módulo: padron_licencias
-- Componentes: 11-15
-- Total SPs: 23
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================'
\echo 'INICIANDO DEPLOY BATCH 3 - PADRON LICENCIAS'
\echo '5 Componentes | 23 Stored Procedures'
\echo '================================================'
\echo ''

-- ============================================
-- COMPONENTE 11: CatRequisitos (4 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/catrequisitos_deploy.sql

-- ============================================
-- COMPONENTE 12: LigaRequisitos (5 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/ligarequisitos_deploy.sql

-- ============================================
-- COMPONENTE 13: ZonaLicencia (5 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/zonalicencia_deploy.sql

-- ============================================
-- COMPONENTE 14: ZonaAnuncio (4 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/zonaanuncio_deploy.sql

-- ============================================
-- COMPONENTE 15: empresasfrm (5 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/empresasfrm_deploy.sql

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

\echo ''
\echo '================================================'
\echo 'VERIFICANDO STORED PROCEDURES DESPLEGADOS'
\echo '================================================'
\echo ''

SELECT 'CatRequisitos' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_cat_requisitos_list', 'sp_cat_requisitos_create', 'sp_cat_requisitos_update', 'sp_cat_requisitos_delete')
ORDER BY proname;

SELECT 'LigaRequisitos' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_ligarequisitos_giros', 'sp_ligarequisitos_list', 'sp_ligarequisitos_available', 'sp_ligarequisitos_add', 'sp_ligarequisitos_remove')
ORDER BY proname;

SELECT 'ZonaLicencia' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_get_licencia', 'sp_get_zonas', 'sp_get_subzonas', 'sp_get_recaudadoras', 'sp_save_licencias_zona')
ORDER BY proname;

SELECT 'ZonaAnuncio' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_zonaanuncio_list', 'sp_zonaanuncio_create', 'sp_zonaanuncio_update', 'sp_zonaanuncio_delete')
ORDER BY proname;

SELECT 'empresasfrm' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_empresas_estadisticas', 'sp_empresas_list', 'sp_empresas_get', 'sp_empresas_create', 'sp_empresas_update', 'sp_empresas_delete')
ORDER BY proname;

\echo ''
\echo '================================================'
\echo 'DEPLOY BATCH 3 COMPLETADO EXITOSAMENTE'
\echo '================================================'
\echo ''
\echo 'RESUMEN:'
\echo '  - CatRequisitos: 4 SPs'
\echo '  - LigaRequisitos: 5 SPs'
\echo '  - ZonaLicencia: 5 SPs'
\echo '  - ZonaAnuncio: 4 SPs'
\echo '  - empresasfrm: 5 SPs'
\echo '  -------------------------'
\echo '  TOTAL: 23 SPs desplegados'
\echo ''
\echo 'PROGRESO MÓDULO: 15/97 componentes (15.5%)'
\echo ''
