-- ============================================
-- DEPLOY BATCH 2 - 5 COMPONENTES ADICIONALES
-- Módulo: padron_licencias
-- Base de Datos: padron_licencias
-- Fecha: 2025-11-20
-- Total SPs: 13
-- ============================================

\echo ''
\echo '================================================'
\echo 'INICIANDO DEPLOY BATCH 2 - 5 COMPONENTES'
\echo '================================================'
\echo ''
\echo 'Componentes a desplegar:'
\echo '  6. buscagirofrm (4 SPs)'
\echo '  7. catalogogirosfrm (6 SPs)'
\echo '  8. Cruces (3 SPs)'
\echo '  9. formabuscalle (2 SPs)'
\echo ' 10. formabuscolonia (2 SPs)'
\echo ''
\echo 'Total: 17 SPs'
\echo ''

-- ============================================
-- COMPONENTE 6: buscagirofrm (4 SPs)
-- ============================================
\echo 'Componente 6: buscagirofrm...'
\i buscagirofrm_deploy.sql

-- ============================================
-- COMPONENTE 7: catalogogirosfrm (6 SPs)
-- ============================================
\echo 'Componente 7: catalogogirosfrm...'
\i catalogogirosfrm_deploy.sql

-- ============================================
-- COMPONENTE 8: Cruces (3 SPs)
-- ============================================
\echo 'Componente 8: Cruces...'
\i cruces_deploy.sql

-- ============================================
-- COMPONENTE 9: formabuscalle (2 SPs)
-- ============================================
\echo 'Componente 9: formabuscalle...'
\i formabuscalle_deploy.sql

-- ============================================
-- COMPONENTE 10: formabuscolonia (2 SPs)
-- ============================================
\echo 'Componente 10: formabuscolonia...'
\i formabuscolonia_deploy.sql

\echo ''
\echo '================================================'
\echo 'DEPLOY BATCH 2 COMPLETADO'
\echo '================================================'
\echo 'Total SPs desplegados: 17'
\echo 'Componentes listos: 10 acumulados (5 + 5)'
\echo ''
\echo 'VERIFICACIÓN FINAL:'

SELECT
    CASE
        WHEN COUNT(*) = 17 THEN '✓ ÉXITO: Los 17 SPs del Batch 2 fueron creados correctamente'
        ELSE '✗ ERROR: Faltan ' || (17 - COUNT(*) || ' SPs'
    END as resultado
FROM pg_proc
WHERE proname IN (
    -- buscagirofrm (4)
    'sp_buscagiro_list',
    'sp_buscagiro_permisos',
    'sp_buscagiro_search',
    'sp_buscagiro_detalle',
    -- catalogogirosfrm (6)
    'sp_catalogogiros_estadisticas',
    'sp_catalogogiros_list',
    'sp_catalogogiros_get',
    'sp_catalogogiros_create',
    'sp_catalogogiros_update',
    'sp_catalogogiros_cambiar_vigencia',
    -- Cruces (3)
    'sp_cruces_search_calle1',
    'sp_cruces_search_calle2',
    'sp_cruces_localiza_calle',
    -- formabuscalle (2)
    'sp_buscar_calles',
    'sp_listar_calles',
    -- formabuscolonia (2)
    'sp_buscar_colonias',
    'sp_obtener_colonia_seleccionada'
)
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

\echo ''
\echo 'Resumen acumulado:'
\echo '  Batch 1 (previo): 5 componentes, 18 SPs'
\echo '  Batch 2 (actual): 5 componentes, 17 SPs'
\echo '  TOTAL: 10 componentes, 35 SPs'
\echo ''
\echo 'Progreso módulo: 10/97 componentes (10.3%)'
\echo ''
