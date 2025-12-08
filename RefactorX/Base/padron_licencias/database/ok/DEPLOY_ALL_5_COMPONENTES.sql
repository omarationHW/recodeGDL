-- ============================================
-- DEPLOY CONSOLIDADO - 5 COMPONENTES COMPLETADOS
-- Módulo: padron_licencias
-- Base de Datos: padron_licencias
-- Fecha: 2025-11-20
-- Total SPs: 18
-- ============================================

-- COMPONENTE 1: Agendavisitasfrm (3 SPs)
-- COMPONENTE 2: BloquearAnunciorm (4 SPs)
-- COMPONENTE 3: BloquearLicenciafrm (4 SPs)
-- COMPONENTE 4: BloquearTramitefrm (5 SPs)
-- COMPONENTE 5: BusquedaActividadFrm (2 SPs)

\echo '================================================'
\echo 'INICIANDO DESPLIEGUE DE 18 STORED PROCEDURES'
\echo '================================================'
\echo ''

-- ============================================
-- COMPONENTE 1: Agendavisitasfrm
-- ============================================
\echo 'Componente 1: Agendavisitasfrm (3 SPs)...'
\i agendavisitasfrm_deploy.sql

-- ============================================
-- COMPONENTE 2: BloquearAnunciorm
-- ============================================
\echo 'Componente 2: BloquearAnunciorm (4 SPs)...'
\i bloqueara_anuncio_deploy.sql

-- ============================================
-- COMPONENTE 3: BloquearLicenciafrm
-- ============================================
\echo 'Componente 3: BloquearLicenciafrm (4 SPs)...'
\i bloquear_licencia_deploy.sql

-- ============================================
-- COMPONENTE 4: BloquearTramitefrm
-- ============================================
\echo 'Componente 4: BloquearTramitefrm (5 SPs)...'
\i bloquear_tramite_deploy.sql

-- ============================================
-- COMPONENTE 5: BusquedaActividadFrm
-- ============================================
\echo 'Componente 5: BusquedaActividadFrm (2 SPs)...'
\i busqueda_actividad_deploy.sql

\echo ''
\echo '================================================'
\echo 'DESPLIEGUE COMPLETADO'
\echo '================================================'
\echo 'Total SPs desplegados: 18'
\echo 'Componentes listos: 5'
\echo ''
\echo 'VERIFICACION:'
SELECT 'Agendavisitasfrm - fn_dialetra' as componente,
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_dialetra')
       THEN 'OK' ELSE 'FALTA' END as estado
UNION ALL
SELECT 'Agendavisitasfrm - sp_get_dependencias',
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'sp_get_dependencias')
       THEN 'OK' ELSE 'FALTA' END
UNION ALL
SELECT 'Agendavisitasfrm - sp_get_agenda_visitas',
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'sp_get_agenda_visitas')
       THEN 'OK' ELSE 'FALTA' END
UNION ALL
SELECT 'BloquearAnunciorm - sp_buscar_anuncio',
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'sp_buscar_anuncio')
       THEN 'OK' ELSE 'FALTA' END
UNION ALL
SELECT 'BloquearAnunciorm - sp_bloquear_anuncio',
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'sp_bloquear_anuncio')
       THEN 'OK' ELSE 'FALTA' END
UNION ALL
SELECT 'BloquearLicenciafrm - sp_buscar_licencia',
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'sp_buscar_licencia')
       THEN 'OK' ELSE 'FALTA' END
UNION ALL
SELECT 'BloquearTramitefrm - sp_buscar_tramite',
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'sp_buscar_tramite')
       THEN 'OK' ELSE 'FALTA' END
UNION ALL
SELECT 'BusquedaActividadFrm - sp_buscar_actividades',
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'sp_buscar_actividades')
       THEN 'OK' ELSE 'FALTA' END;

\echo ''
\echo 'Si todos muestran OK, el despliegue fue exitoso'
\echo ''
