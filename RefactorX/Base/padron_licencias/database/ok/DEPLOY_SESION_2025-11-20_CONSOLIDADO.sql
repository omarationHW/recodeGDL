-- ============================================
-- DEPLOY CONSOLIDADO - SESIÓN 2025-11-20
-- Módulo: padron_licencias
-- Componentes: 7 (consultausuariosfrm, dictamenfrm, constanciafrm, repestado, repdoc, certificacionesfrm, DetalleLicencia)
-- Total SPs: 40
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================================================'
\echo '                  DEPLOY SESIÓN 2025-11-20 - PADRON LICENCIAS'
\echo '================================================================================'
\echo '  7 Componentes | 40 Stored Procedures | ~5,500 líneas de código'
\echo '================================================================================'
\echo ''

-- ============================================
-- PREREQUISITOS
-- ============================================

\echo '▶ Verificando prerequisitos...'
\echo ''

-- Verificar extensión pgcrypto (requerida para consultausuariosfrm)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

\echo '  ✓ Extensión pgcrypto verificada'
\echo ''

-- ============================================
-- BATCH 1 - PRIMERA FASE (19 SPs)
-- ============================================

\echo ''
\echo '================================================================================'
\echo '                              BATCH 1 - PRIMERA FASE'
\echo '                        consultausuariosfrm | dictamenfrm | constanciafrm'
\echo '                                   19 Stored Procedures'
\echo '================================================================================'
\echo ''

-- ============================================
-- COMPONENTE 1: consultausuariosfrm (9 SPs)
-- Schema: comun
-- Gestión de usuarios con bcrypt
-- ============================================

\echo '▶ [1/7] Desplegando consultausuariosfrm (9 SPs)...'
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/CONSULTAUSUARIOS_all_procedures_IMPLEMENTED.sql

\echo '  ✓ consultausuariosfrm desplegado'
\echo '    - sp_get_all_usuarios'
\echo '    - sp_buscar_usuario'
\echo '    - sp_buscar_usuario_por_nombre'
\echo '    - sp_buscar_usuario_por_depto'
\echo '    - sp_crear_usuario (con bcrypt)'
\echo '    - sp_actualizar_usuario'
\echo '    - sp_eliminar_usuario (soft delete)'
\echo '    - sp_get_departamentos'
\echo '    - sp_get_dependencias'
\echo ''

-- ============================================
-- COMPONENTE 2: dictamenfrm (4 SPs)
-- Schema: comun
-- Gestión de dictámenes de uso de suelo
-- ============================================

\echo '▶ [2/7] Desplegando dictamenfrm (4 SPs)...'
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/DICTAMENFRM_all_procedures_IMPLEMENTED.sql

\echo '  ✓ dictamenfrm desplegado'
\echo '    - sp_dictamenes_estadisticas'
\echo '    - sp_dictamenes_list (paginado)'
\echo '    - sp_dictamenes_create'
\echo '    - sp_dictamenes_update'
\echo ''

-- ============================================
-- COMPONENTE 3: constanciafrm (6 SPs)
-- Schema: public
-- Gestión de constancias con auto-folio
-- ============================================

\echo '▶ [3/7] Desplegando constanciafrm (6 SPs)...'
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/CONSTANCIAFRM_all_procedures_IMPLEMENTED.sql

\echo '  ✓ constanciafrm desplegado'
\echo '    - sp_constancias_list'
\echo '    - sp_constancias_get'
\echo '    - sp_constancias_create (auto-folio)'
\echo '    - sp_constancias_update'
\echo '    - sp_constancias_cancel (soft delete)'
\echo '    - sp_constancias_get_next_folio'
\echo ''

-- ============================================
-- BATCH 2 - SEGUNDA FASE (21 SPs)
-- ============================================

\echo ''
\echo '================================================================================'
\echo '                             BATCH 2 - SEGUNDA FASE'
\echo '             repestado | repdoc | certificacionesfrm | DetalleLicencia'
\echo '                                21 Stored Procedures'
\echo '================================================================================'
\echo ''

-- ============================================
-- COMPONENTE 4: repestado (6 SPs)
-- Schema: comun
-- Reportes de estado de trámites
-- ============================================

\echo '▶ [4/7] Desplegando repestado (6 SPs)...'
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/REPESTADO_all_procedures_IMPLEMENTED.sql

\echo '  ✓ repestado desplegado'
\echo '    - sp_repestado_get_tramite_estado (50+ campos)'
\echo '    - sp_repestado_get_tramite_revisiones'
\echo '    - sp_repestado_get_revision_detalle'
\echo '    - sp_repestado_get_dependencia'
\echo '    - sp_repestado_get_giro'
\echo '    - sp_repestado_get_estado_completo (JSON)'
\echo ''

-- ============================================
-- COMPONENTE 5: repdoc (4 SPs)
-- Schema: comun
-- Reportes de documentos y requisitos
-- ============================================

\echo '▶ [5/7] Desplegando repdoc (4 SPs)...'
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/REPDOC_all_procedures_IMPLEMENTED.sql

\echo '  ✓ repdoc desplegado'
\echo '    - sp_repdoc_get_giros (filtros JSONB)'
\echo '    - sp_repdoc_get_requisitos_by_giro'
\echo '    - sp_repdoc_print_requisitos'
\echo '    - sp_repdoc_print_permisos_eventuales'
\echo ''

-- ============================================
-- COMPONENTE 6: certificacionesfrm (7 SPs)
-- Schema: public
-- Gestión de certificaciones con auto-folio
-- ============================================

\echo '▶ [6/7] Desplegando certificacionesfrm (7 SPs)...'
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/CERTIFICACIONESFRM_all_procedures_IMPLEMENTED.sql

\echo '  ✓ certificacionesfrm desplegado'
\echo '    - sp_certificaciones_list'
\echo '    - sp_certificaciones_get'
\echo '    - sp_certificaciones_create (auto-folio)'
\echo '    - sp_certificaciones_update'
\echo '    - sp_certificaciones_cancel (soft delete)'
\echo '    - sp_certificaciones_search (7 filtros)'
\echo '    - sp_certificaciones_print (JSON)'
\echo ''

-- ============================================
-- COMPONENTE 7: DetalleLicencia (4 SPs)
-- Schema: comun
-- Gestión financiera de licencias
-- ============================================

\echo '▶ [7/7] Desplegando DetalleLicencia (4 SPs)...'
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/DETALLELICENCIA_all_procedures_IMPLEMENTED.sql

\echo '  ✓ DetalleLicencia desplegado'
\echo '    - sp_get_saldo_licencia'
\echo '    - sp_get_detalle_licencia'
\echo '    - sp_get_historial_pagos (filtros avanzados)'
\echo '    - sp_calcular_adeudo_licencia (recargos 2%)'
\echo ''

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

\echo ''
\echo '================================================================================'
\echo '                            VERIFICACIÓN FINAL'
\echo '================================================================================'
\echo ''

-- Contar SPs desplegados por schema
\echo '▶ Contando stored procedures desplegados...'
SELECT
    n.nspname as schema,
    COUNT(*) as total_sps
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('comun', 'public')
  AND p.proname LIKE 'sp_%'
GROUP BY n.nspname
ORDER BY n.nspname;

\echo ''
\echo '▶ Verificando SPs por componente...'

-- consultausuariosfrm (9 SPs)
SELECT 'consultausuariosfrm' as componente, COUNT(*) as sps_desplegados
FROM pg_proc
WHERE proname IN (
    'sp_get_all_usuarios',
    'sp_buscar_usuario',
    'sp_buscar_usuario_por_nombre',
    'sp_buscar_usuario_por_depto',
    'sp_crear_usuario',
    'sp_actualizar_usuario',
    'sp_eliminar_usuario',
    'sp_get_departamentos',
    'sp_get_dependencias'
);

-- dictamenfrm (4 SPs)
SELECT 'dictamenfrm' as componente, COUNT(*) as sps_desplegados
FROM pg_proc
WHERE proname IN (
    'sp_dictamenes_estadisticas',
    'sp_dictamenes_list',
    'sp_dictamenes_create',
    'sp_dictamenes_update'
);

-- constanciafrm (6 SPs)
SELECT 'constanciafrm' as componente, COUNT(*) as sps_desplegados
FROM pg_proc
WHERE proname IN (
    'sp_constancias_list',
    'sp_constancias_get',
    'sp_constancias_create',
    'sp_constancias_update',
    'sp_constancias_cancel',
    'sp_constancias_get_next_folio'
);

-- repestado (6 SPs)
SELECT 'repestado' as componente, COUNT(*) as sps_desplegados
FROM pg_proc
WHERE proname IN (
    'sp_repestado_get_tramite_estado',
    'sp_repestado_get_tramite_revisiones',
    'sp_repestado_get_revision_detalle',
    'sp_repestado_get_dependencia',
    'sp_repestado_get_giro',
    'sp_repestado_get_estado_completo'
);

-- repdoc (4 SPs)
SELECT 'repdoc' as componente, COUNT(*) as sps_desplegados
FROM pg_proc
WHERE proname IN (
    'sp_repdoc_get_giros',
    'sp_repdoc_get_requisitos_by_giro',
    'sp_repdoc_print_requisitos',
    'sp_repdoc_print_permisos_eventuales'
);

-- certificacionesfrm (7 SPs)
SELECT 'certificacionesfrm' as componente, COUNT(*) as sps_desplegados
FROM pg_proc
WHERE proname IN (
    'sp_certificaciones_list',
    'sp_certificaciones_get',
    'sp_certificaciones_create',
    'sp_certificaciones_update',
    'sp_certificaciones_cancel',
    'sp_certificaciones_search',
    'sp_certificaciones_print'
);

-- DetalleLicencia (4 SPs)
SELECT 'DetalleLicencia' as componente, COUNT(*) as sps_desplegados
FROM pg_proc
WHERE proname IN (
    'sp_get_saldo_licencia',
    'sp_get_detalle_licencia',
    'sp_get_historial_pagos',
    'sp_calcular_adeudo_licencia'
);

\echo ''
\echo '================================================================================'
\echo '                        DEPLOY COMPLETADO EXITOSAMENTE'
\echo '================================================================================'
\echo ''
\echo 'RESUMEN FINAL:'
\echo ''
\echo '  BATCH 1 (Primera Fase):'
\echo '    ✓ consultausuariosfrm: 9 SPs (schema: comun)'
\echo '    ✓ dictamenfrm: 4 SPs (schema: comun)'
\echo '    ✓ constanciafrm: 6 SPs (schema: public)'
\echo '    ─────────────────────────────'
\echo '    Subtotal: 19 SPs'
\echo ''
\echo '  BATCH 2 (Segunda Fase):'
\echo '    ✓ repestado: 6 SPs (schema: comun)'
\echo '    ✓ repdoc: 4 SPs (schema: comun)'
\echo '    ✓ certificacionesfrm: 7 SPs (schema: public)'
\echo '    ✓ DetalleLicencia: 4 SPs (schema: comun)'
\echo '    ─────────────────────────────'
\echo '    Subtotal: 21 SPs'
\echo ''
\echo '  ═════════════════════════════'
\echo '  TOTAL DESPLEGADO: 40 SPs'
\echo '  ═════════════════════════════'
\echo ''
\echo 'PROGRESO MÓDULO PADRON_LICENCIAS:'
\echo '  - Componentes: 27/95 (28.4%)'
\echo '  - SPs totales: 117 (77 previos + 40 nuevos)'
\echo ''
\echo 'CARACTERÍSTICAS DESTACADAS:'
\echo '  • bcrypt password hashing (consultausuariosfrm)'
\echo '  • Auto-folio generation (constanciafrm, certificacionesfrm)'
\echo '  • Financial calculations (DetalleLicencia - 2% monthly interest)'
\echo '  • JSONB dynamic filters (repdoc)'
\echo '  • Soft delete with audit trail (múltiples componentes)'
\echo '  • Window functions optimization (paginación)'
\echo ''
\echo 'PRÓXIMOS PASOS:'
\echo '  1. Verificar que todos los SPs estén listados arriba'
\echo '  2. Ejecutar tests con: CONSULTAUSUARIOS_PRUEBAS.sql'
\echo '  3. Iniciar servidor Laravel: php artisan serve'
\echo '  4. Probar componentes Vue en navegador'
\echo ''
\echo '================================================================================'
\echo '                                   ¡LISTO!'
\echo '================================================================================'
\echo ''
