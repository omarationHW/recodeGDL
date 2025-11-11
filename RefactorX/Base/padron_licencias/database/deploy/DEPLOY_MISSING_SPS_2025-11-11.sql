-- ================================================================
-- DEPLOYMENT SCRIPT: padron_licencias
-- SPs Faltantes: 49
-- Fecha: 2025-11-11
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: padron_licencias
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: padron_licencias - 49 SPs'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;


-- [1/49] constancias_get_next_folio - 2 usos (🟡 MEDIA)
\echo 'Creando: constancias_get_next_folio...'
\i ../generated/constancias_get_next_folio.sql
\echo '   ✓ OK'

-- [2/49] consulta_licencias_list - 2 usos (🟡 MEDIA)
\echo 'Creando: consulta_licencias_list...'
\i ../generated/consulta_licencias_list.sql
\echo '   ✓ OK'

-- [3/49] sp_giros_dcon_adeudo - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_giros_dcon_adeudo...'
\i ../generated/sp_giros_dcon_adeudo.sql
\echo '   ✓ OK'

-- [4/49] sp_report_giros_dcon_adeudo - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_report_giros_dcon_adeudo...'
\i ../generated/sp_report_giros_dcon_adeudo.sql
\echo '   ✓ OK'

-- [5/49] sp_bloquearanuncio_get_anuncio - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearanuncio_get_anuncio...'
\i ../generated/sp_bloquearanuncio_get_anuncio.sql
\echo '   ✓ OK'

-- [6/49] sp_bloquearanuncio_get_bloqueos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearanuncio_get_bloqueos...'
\i ../generated/sp_bloquearanuncio_get_bloqueos.sql
\echo '   ✓ OK'

-- [7/49] sp_bloquearanuncio_bloquear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearanuncio_bloquear...'
\i ../generated/sp_bloquearanuncio_bloquear.sql
\echo '   ✓ OK'

-- [8/49] sp_bloquearanuncio_desbloquear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearanuncio_desbloquear...'
\i ../generated/sp_bloquearanuncio_desbloquear.sql
\echo '   ✓ OK'

-- [9/49] sp_bloquearlicencia_get_licencia - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearlicencia_get_licencia...'
\i ../generated/sp_bloquearlicencia_get_licencia.sql
\echo '   ✓ OK'

-- [10/49] sp_bloquearlicencia_get_bloqueos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearlicencia_get_bloqueos...'
\i ../generated/sp_bloquearlicencia_get_bloqueos.sql
\echo '   ✓ OK'

-- [11/49] sp_bloquearlicencia_bloquear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearlicencia_bloquear...'
\i ../generated/sp_bloquearlicencia_bloquear.sql
\echo '   ✓ OK'

-- [12/49] sp_bloquearlicencia_desbloquear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloquearlicencia_desbloquear...'
\i ../generated/sp_bloquearlicencia_desbloquear.sql
\echo '   ✓ OK'

-- [13/49] sp_bloqueartramite_get_tramite - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueartramite_get_tramite...'
\i ../generated/sp_bloqueartramite_get_tramite.sql
\echo '   ✓ OK'

-- [14/49] sp_bloqueartramite_get_bloqueos - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueartramite_get_bloqueos...'
\i ../generated/sp_bloqueartramite_get_bloqueos.sql
\echo '   ✓ OK'

-- [15/49] sp_bloqueartramite_get_giro - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueartramite_get_giro...'
\i ../generated/sp_bloqueartramite_get_giro.sql
\echo '   ✓ OK'

-- [16/49] sp_bloqueartramite_bloquear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueartramite_bloquear...'
\i ../generated/sp_bloqueartramite_bloquear.sql
\echo '   ✓ OK'

-- [17/49] sp_bloqueartramite_desbloquear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueartramite_desbloquear...'
\i ../generated/sp_bloqueartramite_desbloquear.sql
\echo '   ✓ OK'

-- [18/49] sp_bloqueodomicilios_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueodomicilios_update...'
\i ../generated/sp_bloqueodomicilios_update.sql
\echo '   ✓ OK'

-- [19/49] sp_bloqueodomicilios_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueodomicilios_create...'
\i ../generated/sp_bloqueodomicilios_create.sql
\echo '   ✓ OK'

-- [20/49] sp_bloqueodomicilios_cancel - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueodomicilios_cancel...'
\i ../generated/sp_bloqueodomicilios_cancel.sql
\echo '   ✓ OK'

-- [21/49] sp_bloqueorfc_buscar_tramite - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueorfc_buscar_tramite...'
\i ../generated/sp_bloqueorfc_buscar_tramite.sql
\echo '   ✓ OK'

-- [22/49] sp_bloqueorfc_create - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueorfc_create...'
\i ../generated/sp_bloqueorfc_create.sql
\echo '   ✓ OK'

-- [23/49] sp_bloqueorfc_desbloquear - 1 usos (⚪ BAJA)
\echo 'Creando: sp_bloqueorfc_desbloquear...'
\i ../generated/sp_bloqueorfc_desbloquear.sql
\echo '   ✓ OK'

-- [24/49] certificaciones_list - 1 usos (⚪ BAJA)
\echo 'Creando: certificaciones_list...'
\i ../generated/certificaciones_list.sql
\echo '   ✓ OK'

-- [25/49] certificaciones_estadisticas - 1 usos (⚪ BAJA)
\echo 'Creando: certificaciones_estadisticas...'
\i ../generated/certificaciones_estadisticas.sql
\echo '   ✓ OK'

-- [26/49] certificaciones_get_next_folio - 1 usos (⚪ BAJA)
\echo 'Creando: certificaciones_get_next_folio...'
\i ../generated/certificaciones_get_next_folio.sql
\echo '   ✓ OK'

-- [27/49] certificaciones_create - 1 usos (⚪ BAJA)
\echo 'Creando: certificaciones_create...'
\i ../generated/certificaciones_create.sql
\echo '   ✓ OK'

-- [28/49] certificaciones_update - 1 usos (⚪ BAJA)
\echo 'Creando: certificaciones_update...'
\i ../generated/certificaciones_update.sql
\echo '   ✓ OK'

-- [29/49] certificaciones_delete - 1 usos (⚪ BAJA)
\echo 'Creando: certificaciones_delete...'
\i ../generated/certificaciones_delete.sql
\echo '   ✓ OK'

-- [30/49] constancias_list - 1 usos (⚪ BAJA)
\echo 'Creando: constancias_list...'
\i ../generated/constancias_list.sql
\echo '   ✓ OK'

-- [31/49] constancias_estadisticas - 1 usos (⚪ BAJA)
\echo 'Creando: constancias_estadisticas...'
\i ../generated/constancias_estadisticas.sql
\echo '   ✓ OK'

-- [32/49] constancias_create - 1 usos (⚪ BAJA)
\echo 'Creando: constancias_create...'
\i ../generated/constancias_create.sql
\echo '   ✓ OK'

-- [33/49] constancias_update - 1 usos (⚪ BAJA)
\echo 'Creando: constancias_update...'
\i ../generated/constancias_update.sql
\echo '   ✓ OK'

-- [34/49] constancias_delete - 1 usos (⚪ BAJA)
\echo 'Creando: constancias_delete...'
\i ../generated/constancias_delete.sql
\echo '   ✓ OK'

-- [35/49] sp_solicnooficial_list - 1 usos (⚪ BAJA)
\echo 'Creando: sp_solicnooficial_list...'
\i ../generated/sp_solicnooficial_list.sql
\echo '   ✓ OK'

-- [36/49] consulta_anuncios_list - 1 usos (⚪ BAJA)
\echo 'Creando: consulta_anuncios_list...'
\i ../generated/consulta_anuncios_list.sql
\echo '   ✓ OK'

-- [37/49] consulta_tramites_list - 1 usos (⚪ BAJA)
\echo 'Creando: consulta_tramites_list...'
\i ../generated/consulta_tramites_list.sql
\echo '   ✓ OK'

-- [38/49] h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom - 1 usos (⚪ BAJA)
\echo 'Creando: h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom...'
\i ../generated/h_bloqueodomiciliosfrm_sp_filter_h_bloqueo_dom.sql
\echo '   ✓ OK'

-- [39/49] h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle - 1 usos (⚪ BAJA)
\echo 'Creando: h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle...'
\i ../generated/h_bloqueodomiciliosfrm_sp_h_bloqueo_dom_detalle.sql
\echo '   ✓ OK'

-- [40/49] h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel - 1 usos (⚪ BAJA)
\echo 'Creando: h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel...'
\i ../generated/h_bloqueodomiciliosfrm_sp_exportar_h_bloqueo_dom_excel.sql
\echo '   ✓ OK'

-- [41/49] h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report - 1 usos (⚪ BAJA)
\echo 'Creando: h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report...'
\i ../generated/h_bloqueodomiciliosfrm_sp_imprimir_h_bloqueo_dom_report.sql
\echo '   ✓ OK'

-- [42/49] sp_get_licencia_reglamentada - 1 usos (⚪ BAJA)
\echo 'Creando: sp_get_licencia_reglamentada...'
\i ../generated/sp_get_licencia_reglamentada.sql
\echo '   ✓ OK'

-- [43/49] sp_check_licencia_bloqueada - 1 usos (⚪ BAJA)
\echo 'Creando: sp_check_licencia_bloqueada...'
\i ../generated/sp_check_licencia_bloqueada.sql
\echo '   ✓ OK'

-- [44/49] sp_calcular_adeudo_licencia - 1 usos (⚪ BAJA)
\echo 'Creando: sp_calcular_adeudo_licencia...'
\i ../generated/sp_calcular_adeudo_licencia.sql
\echo '   ✓ OK'

-- [45/49] sp_detalle_saldo_licencia - 1 usos (⚪ BAJA)
\echo 'Creando: sp_detalle_saldo_licencia...'
\i ../generated/sp_detalle_saldo_licencia.sql
\echo '   ✓ OK'

-- [46/49] licenciasvigentesfrm_sp_stats - 1 usos (⚪ BAJA)
\echo 'Creando: licenciasvigentesfrm_sp_stats...'
\i ../generated/licenciasvigentesfrm_sp_stats.sql
\echo '   ✓ OK'

-- [47/49] licenciasvigentesfrm_sp_licencias_vigentes - 1 usos (⚪ BAJA)
\echo 'Creando: licenciasvigentesfrm_sp_licencias_vigentes...'
\i ../generated/licenciasvigentesfrm_sp_licencias_vigentes.sql
\echo '   ✓ OK'

-- [48/49] sgcv2_sp_save_process - 1 usos (⚪ BAJA)
\echo 'Creando: sgcv2_sp_save_process...'
\i ../generated/sgcv2_sp_save_process.sql
\echo '   ✓ OK'

-- [49/49] sp_tipobloqueo_update - 1 usos (⚪ BAJA)
\echo 'Creando: sp_tipobloqueo_update...'
\i ../generated/sp_tipobloqueo_update.sql
\echo '   ✓ OK'

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO: 49 SPs creados'
\echo '=================================================='
\echo ''
