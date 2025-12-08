-- ============================================
-- DEPLOY CONSOLIDADO - BATCH 4
-- Módulo: padron_licencias
-- Componentes: 16-20
-- Total SPs: 19
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================'
\echo 'INICIANDO DEPLOY BATCH 4 - PADRON LICENCIAS'
\echo '5 Componentes | 19 Stored Procedures'
\echo '================================================'
\echo ''

-- ============================================
-- COMPONENTE 16: ligaAnunciofrm (4 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/ligaanunciofrm_deploy.sql

-- ============================================
-- COMPONENTE 17: bloqueoDomiciliosfrm (4 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/bloqueodomiciliosfrm_deploy.sql

-- ============================================
-- COMPONENTE 18: bloqueoRFCfrm (4 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/bloqueorfcfrm_deploy.sql

-- ============================================
-- COMPONENTE 19: bajaAnunciofrm (3 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/bajaanunciofrm_deploy.sql

-- ============================================
-- COMPONENTE 20: bajaLicenciafrm (4 SPs)
-- ============================================

\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/bajalicenciafrm_deploy.sql

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

\echo ''
\echo '================================================'
\echo 'VERIFICANDO STORED PROCEDURES DESPLEGADOS'
\echo '================================================'
\echo ''

SELECT 'ligaAnunciofrm' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_buscar_licencia', 'sp_buscar_empresa', 'sp_buscar_anuncio', 'sp_ligar_anuncio')
ORDER BY proname;

SELECT 'bloqueoDomiciliosfrm' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_bloqueodomicilios_list', 'sp_bloqueodomicilios_create', 'sp_bloqueodomicilios_update', 'sp_bloqueodomicilios_cancel')
ORDER BY proname;

SELECT 'bloqueoRFCfrm' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_bloqueorfc_list', 'sp_bloqueorfc_buscar_tramite', 'sp_bloqueorfc_create', 'sp_bloqueorfc_desbloquear')
ORDER BY proname;

SELECT 'bajaAnunciofrm' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_baja_anuncio_buscar', 'sp_verifica_firma', 'sp_baja_anuncio_procesar')
ORDER BY proname;

SELECT 'bajaLicenciafrm' as componente, proname as stored_procedure
FROM pg_proc
WHERE proname IN ('sp_baja_licencia_consulta', 'sp_consulta_anuncios_licencia', 'sp_verifica_firma_usuario', 'sp_baja_licencia')
ORDER BY proname;

\echo ''
\echo '================================================'
\echo 'DEPLOY BATCH 4 COMPLETADO EXITOSAMENTE'
\echo '================================================'
\echo ''
\echo 'RESUMEN:'
\echo '  - ligaAnunciofrm: 4 SPs'
\echo '  - bloqueoDomiciliosfrm: 4 SPs'
\echo '  - bloqueoRFCfrm: 4 SPs'
\echo '  - bajaAnunciofrm: 3 SPs'
\echo '  - bajaLicenciafrm: 4 SPs'
\echo '  -------------------------'
\echo '  TOTAL: 19 SPs desplegados'
\echo ''
\echo 'PROGRESO MÓDULO: 20/97 componentes (20.6%)'
\echo ''
