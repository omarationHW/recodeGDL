-- ============================================
-- SCRIPT DE VERIFICACIÓN COMPLETA
-- Módulo: padron_licencias
-- Fecha: 2025-11-21
-- ============================================

-- Verificar extensión pgcrypto
SELECT 'pgcrypto' as extension,
       CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto')
            THEN '✅ INSTALADA' ELSE '❌ FALTA' END as estado;

-- ============================================
-- CONTEO TOTAL DE SPs POR SCHEMA
-- ============================================
SELECT
    n.nspname as schema,
    COUNT(*) as total_funciones
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('public', 'comun')
  AND p.prokind = 'f'
GROUP BY n.nspname
ORDER BY n.nspname;

-- ============================================
-- VERIFICACIÓN POR COMPONENTE (BATCH 1-16)
-- ============================================

-- Función auxiliar para contar SPs por patrón
DO $$
DECLARE
    v_count INTEGER;
    v_total INTEGER := 0;
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'VERIFICACIÓN DE STORED PROCEDURES POR COMPONENTE';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';

    -- BATCH 1
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%consultausuario%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 1 - consultausuariosfrm: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%dictamen%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 1 - dictamenfrm: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%constancia%' AND p.proname NOT LIKE '%nooficial%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 1 - constanciafrm: % SPs', v_count;

    -- BATCH 2
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%repestado%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 2 - repestado: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%repdoc%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 2 - repdoc: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%certificacion%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 2 - certificacionesfrm: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%detalle_licencia%' OR p.proname LIKE '%get_saldo_licencia%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 2 - DetalleLicencia: % SPs', v_count;

    -- BATCH 3
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%privilegio%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 3 - privilegios: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%doctos%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 3 - doctosfrm: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%tipobloqueo%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 3 - tipobloqueofrm: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%dependencia%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 3 - dependenciasfrm: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND p.proname LIKE '%ecologia%';
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 3 - formatosEcologiafrm: % SPs', v_count;

    -- BATCH 4-6 (resumen)
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%consultalicencia%' OR
        p.proname LIKE '%cancelatramite%' OR
        p.proname LIKE '%reactivatramite%' OR
        p.proname LIKE '%scian%' OR
        p.proname LIKE '%nooficial%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 4 - consultas/cancelaciones: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%actividad%' OR
        p.proname LIKE '%consanun400%' OR
        p.proname LIKE '%conslic400%' OR
        p.proname LIKE '%estatus%' OR
        p.proname LIKE '%cartonva%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 5 - actividades/estatus: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%grupos_licencia%' OR
        p.proname LIKE '%hasta%' OR
        p.proname LIKE '%imp_licencia%' OR
        p.proname LIKE '%imp_oficio%' OR
        p.proname LIKE '%imp_recibo%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 6 - grupos/impresiones: % SPs', v_count;

    -- BATCH 7-9
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%licenciasvigentes%' OR
        p.proname LIKE '%ligarequisitos%' OR
        p.proname LIKE '%propuestatab%' OR
        p.proname LIKE '%registrosolicitud%' OR
        p.proname LIKE '%reporteanun%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 7 - licencias vigentes: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%bloquear%' OR
        p.proname LIKE '%bloqueo%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 8 - bloqueos: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%prepago%' OR
        p.proname LIKE '%holograma%' OR
        p.proname LIKE '%propuesta%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 9 - prepagos/hologramas: % SPs', v_count;

    -- BATCH 10-12
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%agenda%' OR
        p.proname LIKE '%buscagiro%' OR
        p.proname LIKE '%busque%' OR
        p.proname LIKE '%cargadatos%' OR
        p.proname LIKE '%carga_%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 10 - agenda/búsqueda: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%imagen%' OR
        p.proname LIKE '%catastro%' OR
        p.proname LIKE '%cruces%' OR
        p.proname LIKE '%empresa%' OR
        p.proname LIKE '%buscalle%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 11 - imágenes/catastro: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%catrequisitos%' OR
        p.proname LIKE '%firmausuario%' OR
        p.proname LIKE '%buscolonia%' OR
        p.proname LIKE '%grs_dlg%' OR
        p.proname LIKE '%grupos_anuncio%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 12 - requisitos/firma: % SPs', v_count;

    -- BATCH 13-14
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%firma%' AND p.proname NOT LIKE '%firmausuario%' OR
        p.proname LIKE '%frmselcalle%' OR
        p.proname LIKE '%liga_anuncio%' OR
        p.proname LIKE '%psplash%' OR
        p.proname LIKE '%observacion%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 13 - firma/liga anuncios: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%semaforo%' OR
        p.proname LIKE '%sgcv2%' OR
        p.proname LIKE '%tdmconection%' OR
        p.proname LIKE '%giros_vigentes%' OR
        p.proname LIKE '%calc_sdos%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 14 - semáforo/SGC: % SPs', v_count;

    -- BATCH 15-16
    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%reghfrm%' OR
        p.proname LIKE '%rep_estadistico%' OR
        p.proname LIKE '%suspendida%' OR
        p.proname LIKE '%chgfirma%' OR
        p.proname LIKE '%chgpass%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 15 - históricos/seguridad: % SPs', v_count;

    SELECT COUNT(*) INTO v_count FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('public','comun') AND (
        p.proname LIKE '%tipo_bloqueo%' OR
        p.proname LIKE '%webbrowser%' OR
        p.proname LIKE '%fechasegfrm%'
    );
    v_total := v_total + v_count;
    RAISE NOTICE 'Batch 16 - tipos bloqueo/web: % SPs', v_count;

    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'TOTAL SPs VERIFICADOS: %', v_total;
    RAISE NOTICE '================================================';
END $$;

-- ============================================
-- LISTADO COMPLETO DE SPs EN SCHEMA COMUN
-- ============================================
SELECT
    p.proname as nombre_sp,
    pg_get_function_arguments(p.oid) as parametros,
    CASE p.provolatile
        WHEN 'i' THEN 'IMMUTABLE'
        WHEN 's' THEN 'STABLE'
        WHEN 'v' THEN 'VOLATILE'
    END as volatilidad
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'comun'
  AND p.prokind = 'f'
ORDER BY p.proname
LIMIT 50;

-- ============================================
-- VERIFICAR TABLAS AUXILIARES CREADAS
-- ============================================
SELECT
    schemaname as schema,
    tablename as tabla,
    '✅ EXISTE' as estado
FROM pg_tables
WHERE schemaname = 'comun'
  AND tablename IN (
    'usuarios', 'licencias', 'anuncios', 'tramites', 'c_giros',
    'bitacora_conexiones', 'bitacora_saldos', 'bitacora_cambio_firma',
    'bitacora_cambio_password', 'password_history', 'usuarios_firma',
    'semaforo_historial', 'navigation_events', 'bookmarks',
    'h_catastro', 'fechasegfrm', 'c_tipobloqueo', 'c_tipos_suspension',
    'sgc_tramites', 'predios'
  )
ORDER BY tablename;

-- ============================================
-- RESUMEN FINAL
-- ============================================
SELECT
    'RESUMEN VERIFICACIÓN' as titulo,
    (SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
     WHERE n.nspname = 'comun' AND p.prokind = 'f') as sps_en_comun,
    (SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
     WHERE n.nspname = 'public' AND p.prokind = 'f') as sps_en_public,
    (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'comun') as tablas_en_comun;
