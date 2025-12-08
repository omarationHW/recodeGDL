-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS - REPDOC
-- Componente: repdoc (Reporte de Documentos y Requisitos)
-- Schema: comun
-- Total SPs: 4
-- Generado: 2025-11-20
-- ============================================
-- Descripción:
--   Componente para gestión y generación de reportes de requisitos
--   documentales para giros y permisos eventuales
-- ============================================

\echo '============================================'
\echo 'Desplegando SPs del componente REPDOC'
\echo 'Schema: comun'
\echo 'Total SPs: 4'
\echo '============================================'

-- ============================================
-- SP 1/4: repdoc_get_giros
-- Tipo: CONSULTA
-- Descripción: Obtiene catálogo de giros filtrado por tipo con paginación
-- Parámetros:
--   - p_filtros: Filtros (tipo, vigente, busqueda, limit, offset)
-- Retorna: JSONB con listado de giros
-- ============================================

CREATE OR REPLACE FUNCTION comun.repdoc_get_giros(
    p_filtros JSONB DEFAULT '{}'::JSONB
)
RETURNS TABLE(
    resultado JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_limit INTEGER := COALESCE((p_filtros->>'limit')::INTEGER, 50);
    v_offset INTEGER := COALESCE((p_filtros->>'offset')::INTEGER, 0);
    v_tipo VARCHAR := p_filtros->>'tipo';
    v_vigente VARCHAR := COALESCE(p_filtros->>'vigente', 'V');
    v_busqueda VARCHAR := p_filtros->>'busqueda';
    v_clasificacion VARCHAR := p_filtros->>'clasificacion';
    v_total INTEGER;
    v_data JSONB;
BEGIN
    -- Validaciones
    IF v_limit < 1 OR v_limit > 1000 THEN
        v_limit := 50;
    END IF;

    IF v_offset < 0 THEN
        v_offset := 0;
    END IF;

    -- Construir consulta con filtros dinámicos
    WITH giros_filtrados AS (
        SELECT
            g.id_giro,
            g.descripcion,
            g.clasificacion,
            g.tipo,
            g.caracteristicas,
            g.vigente,
            g.fecha_creacion
        FROM comun.c_giros g
        WHERE 1=1
            AND (v_tipo IS NULL OR g.tipo = v_tipo)
            AND (v_vigente IS NULL OR g.vigente = v_vigente)
            AND (v_clasificacion IS NULL OR g.clasificacion = v_clasificacion)
            AND (
                v_busqueda IS NULL
                OR UPPER(g.descripcion) LIKE '%' || UPPER(v_busqueda) || '%'
                OR UPPER(g.caracteristicas) LIKE '%' || UPPER(v_busqueda) || '%'
            )
        ORDER BY g.descripcion
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM giros_filtrados
    ),
    giros_paginados AS (
        SELECT * FROM giros_filtrados
        LIMIT v_limit
        OFFSET v_offset
    )
    SELECT
        (SELECT total FROM total_count) INTO v_total;

    -- Construir array JSONB con resultados
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'id_giro', g.id_giro,
                'descripcion', g.descripcion,
                'clasificacion', g.clasificacion,
                'tipo', g.tipo,
                'caracteristicas', g.caracteristicas,
                'vigente', g.vigente,
                'fecha_creacion', g.fecha_creacion
            )
            ORDER BY g.descripcion
        ),
        '[]'::jsonb
    ) INTO v_data
    FROM giros_filtrados g
    LIMIT v_limit
    OFFSET v_offset;

    -- Retornar resultado
    RETURN QUERY
    SELECT jsonb_build_object(
        'success', true,
        'message', 'Giros obtenidos exitosamente',
        'data', v_data,
        'total', COALESCE(v_total, 0),
        'limit', v_limit,
        'offset', v_offset,
        'filtros_aplicados', jsonb_build_object(
            'tipo', v_tipo,
            'vigente', v_vigente,
            'busqueda', v_busqueda,
            'clasificacion', v_clasificacion
        )
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT jsonb_build_object(
            'success', false,
            'message', 'Error al obtener giros: ' || SQLERRM,
            'data', '[]'::jsonb,
            'total', 0,
            'error_code', SQLSTATE
        );
END;
$$;

COMMENT ON FUNCTION comun.repdoc_get_giros(JSONB) IS
'Obtiene catálogo de giros con filtros dinámicos y paginación. Soporta filtros por tipo, vigencia, clasificación y búsqueda por texto';

\echo 'SP 1/4 creado: repdoc_get_giros'

-- ============================================
-- SP 2/4: repdoc_get_requisitos_by_giro
-- Tipo: CONSULTA
-- Descripción: Obtiene requisitos documentales para un giro específico
-- Parámetros:
--   - p_filtros: Filtros (id_giro, limit, offset)
-- Retorna: JSONB con listado de requisitos del giro
-- ============================================

CREATE OR REPLACE FUNCTION comun.repdoc_get_requisitos_by_giro(
    p_filtros JSONB DEFAULT '{}'::JSONB
)
RETURNS TABLE(
    resultado JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_giro INTEGER := (p_filtros->>'id_giro')::INTEGER;
    v_limit INTEGER := COALESCE((p_filtros->>'limit')::INTEGER, 100);
    v_offset INTEGER := COALESCE((p_filtros->>'offset')::INTEGER, 0);
    v_total INTEGER;
    v_data JSONB;
    v_giro_info JSONB;
BEGIN
    -- Validación de parámetro obligatorio
    IF v_id_giro IS NULL THEN
        RETURN QUERY
        SELECT jsonb_build_object(
            'success', false,
            'message', 'El parámetro id_giro es obligatorio',
            'data', '[]'::jsonb,
            'total', 0
        );
        RETURN;
    END IF;

    -- Validar que el giro existe
    SELECT jsonb_build_object(
        'id_giro', g.id_giro,
        'descripcion', g.descripcion,
        'clasificacion', g.clasificacion,
        'tipo', g.tipo
    ) INTO v_giro_info
    FROM comun.c_giros g
    WHERE g.id_giro = v_id_giro;

    IF v_giro_info IS NULL THEN
        RETURN QUERY
        SELECT jsonb_build_object(
            'success', false,
            'message', 'Giro no encontrado con id: ' || v_id_giro,
            'data', '[]'::jsonb,
            'total', 0
        );
        RETURN;
    END IF;

    -- Validaciones
    IF v_limit < 1 OR v_limit > 1000 THEN
        v_limit := 100;
    END IF;

    IF v_offset < 0 THEN
        v_offset := 0;
    END IF;

    -- Obtener requisitos del giro
    -- Nota: Asumiendo tablas giro_req (relación) y c_girosreq (catálogo requisitos)
    WITH requisitos_giro AS (
        SELECT
            gr.req,
            cgr.descripcion,
            cgr.requisitos,
            cgr.vigente,
            gr.obligatorio,
            gr.orden
        FROM comun.giro_req gr
        INNER JOIN comun.c_girosreq cgr ON cgr.req = gr.req
        WHERE gr.id_giro = v_id_giro
            AND (cgr.vigente IS NULL OR cgr.vigente = 'V')
        ORDER BY
            COALESCE(gr.orden, 999),
            gr.req
    )
    SELECT COUNT(*) INTO v_total FROM requisitos_giro;

    -- Construir array JSONB con resultados
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'req', r.req,
                'descripcion', r.descripcion,
                'requisitos', r.requisitos,
                'vigente', r.vigente,
                'obligatorio', COALESCE(r.obligatorio, true),
                'orden', COALESCE(r.orden, 999)
            )
        ),
        '[]'::jsonb
    ) INTO v_data
    FROM (
        SELECT
            gr.req,
            cgr.descripcion,
            cgr.requisitos,
            cgr.vigente,
            gr.obligatorio,
            gr.orden
        FROM comun.giro_req gr
        INNER JOIN comun.c_girosreq cgr ON cgr.req = gr.req
        WHERE gr.id_giro = v_id_giro
            AND (cgr.vigente IS NULL OR cgr.vigente = 'V')
        ORDER BY
            COALESCE(gr.orden, 999),
            gr.req
        LIMIT v_limit
        OFFSET v_offset
    ) r;

    -- Retornar resultado
    RETURN QUERY
    SELECT jsonb_build_object(
        'success', true,
        'message', 'Requisitos obtenidos exitosamente',
        'data', v_data,
        'total', COALESCE(v_total, 0),
        'limit', v_limit,
        'offset', v_offset,
        'giro', v_giro_info
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT jsonb_build_object(
            'success', false,
            'message', 'Error al obtener requisitos: ' || SQLERRM,
            'data', '[]'::jsonb,
            'total', 0,
            'error_code', SQLSTATE
        );
END;
$$;

COMMENT ON FUNCTION comun.repdoc_get_requisitos_by_giro(JSONB) IS
'Obtiene requisitos documentales asociados a un giro específico con información detallada de cada requisito';

\echo 'SP 2/4 creado: repdoc_get_requisitos_by_giro'

-- ============================================
-- SP 3/4: repdoc_print_requisitos
-- Tipo: REPORTE
-- Descripción: Genera datos para reporte de requisitos por giro
-- Parámetros:
--   - p_params: Parámetros (id_giro, formato, incluir_descripciones)
-- Retorna: JSONB con datos formateados para impresión
-- ============================================

CREATE OR REPLACE FUNCTION comun.repdoc_print_requisitos(
    p_params JSONB DEFAULT '{}'::JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_giro INTEGER := (p_params->>'id_giro')::INTEGER;
    v_formato VARCHAR := COALESCE(p_params->>'formato', 'PDF');
    v_incluir_desc BOOLEAN := COALESCE((p_params->>'incluir_descripciones')::BOOLEAN, true);
    v_titulo VARCHAR := p_params->>'titulo';
    v_giro_info RECORD;
    v_requisitos JSONB;
    v_resultado JSONB;
    v_fecha_reporte TIMESTAMP := NOW();
BEGIN
    -- Validación de parámetro obligatorio
    IF v_id_giro IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'El parámetro id_giro es obligatorio para generar el reporte',
            'data', NULL
        );
    END IF;

    -- Obtener información del giro
    SELECT
        g.id_giro,
        g.descripcion,
        g.clasificacion,
        g.tipo,
        g.caracteristicas,
        g.vigente
    INTO v_giro_info
    FROM comun.c_giros g
    WHERE g.id_giro = v_id_giro;

    IF v_giro_info IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Giro no encontrado con id: ' || v_id_giro,
            'data', NULL
        );
    END IF;

    -- Obtener requisitos del giro
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'numero', r.req,
                'descripcion', r.descripcion,
                'detalle', CASE
                    WHEN v_incluir_desc THEN r.requisitos
                    ELSE NULL
                END,
                'obligatorio', COALESCE(r.obligatorio, true),
                'vigente', r.vigente
            )
            ORDER BY COALESCE(r.orden, 999), r.req
        ),
        '[]'::jsonb
    ) INTO v_requisitos
    FROM (
        SELECT
            gr.req,
            cgr.descripcion,
            cgr.requisitos,
            cgr.vigente,
            gireq.obligatorio,
            gireq.orden
        FROM comun.giro_req gireq
        INNER JOIN comun.c_girosreq cgr ON cgr.req = gireq.req
        LEFT JOIN comun.giro_req gr ON gr.id_giro = v_id_giro AND gr.req = cgr.req
        WHERE gireq.id_giro = v_id_giro
            AND (cgr.vigente IS NULL OR cgr.vigente = 'V')
    ) r;

    -- Construir resultado del reporte
    v_resultado := jsonb_build_object(
        'success', true,
        'message', 'Reporte generado exitosamente',
        'data', jsonb_build_object(
            'reporte', jsonb_build_object(
                'titulo', COALESCE(v_titulo, 'Requisitos Documentales para Giro'),
                'formato', v_formato,
                'fecha_generacion', v_fecha_reporte,
                'giro', jsonb_build_object(
                    'id_giro', v_giro_info.id_giro,
                    'descripcion', v_giro_info.descripcion,
                    'clasificacion', v_giro_info.clasificacion,
                    'tipo', CASE v_giro_info.tipo
                        WHEN 'L' THEN 'Licencia'
                        WHEN 'A' THEN 'Anuncio'
                        WHEN 'E' THEN 'Eventual'
                        ELSE v_giro_info.tipo
                    END,
                    'caracteristicas', v_giro_info.caracteristicas,
                    'vigente', v_giro_info.vigente
                ),
                'requisitos', v_requisitos,
                'total_requisitos', jsonb_array_length(v_requisitos),
                'incluye_descripciones', v_incluir_desc
            ),
            'metadata', jsonb_build_object(
                'generado_por', 'Sistema de Padrón de Licencias',
                'modulo', 'repdoc - Reporte de Documentos',
                'fecha', v_fecha_reporte,
                'formato_salida', v_formato
            )
        )
    );

    RETURN v_resultado;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Error al generar reporte de requisitos: ' || SQLERRM,
            'data', NULL,
            'error_code', SQLSTATE
        );
END;
$$;

COMMENT ON FUNCTION comun.repdoc_print_requisitos(JSONB) IS
'Genera datos estructurados para reporte de requisitos documentales de un giro, con formato adaptable para PDF o impresión';

\echo 'SP 3/4 creado: repdoc_print_requisitos'

-- ============================================
-- SP 4/4: repdoc_print_permisos_eventuales
-- Tipo: REPORTE
-- Descripción: Genera reporte de requisitos para permisos eventuales
-- Parámetros:
--   - p_params: Parámetros (tipo_permiso, formato, periodo)
-- Retorna: JSONB con datos del reporte de permisos eventuales
-- ============================================

CREATE OR REPLACE FUNCTION comun.repdoc_print_permisos_eventuales(
    p_params JSONB DEFAULT '{}'::JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo_permiso VARCHAR := p_params->>'tipo_permiso';
    v_formato VARCHAR := COALESCE(p_params->>'formato', 'PDF');
    v_incluir_desc BOOLEAN := COALESCE((p_params->>'incluir_descripciones')::BOOLEAN, true);
    v_titulo VARCHAR := p_params->>'titulo';
    v_periodo VARCHAR := p_params->>'periodo';
    v_giros_eventuales JSONB;
    v_requisitos_comunes JSONB;
    v_resultado JSONB;
    v_fecha_reporte TIMESTAMP := NOW();
    v_total_giros INTEGER;
BEGIN
    -- Obtener giros de tipo eventual (E)
    SELECT
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'id_giro', g.id_giro,
                    'descripcion', g.descripcion,
                    'clasificacion', g.clasificacion,
                    'caracteristicas', g.caracteristicas
                )
                ORDER BY g.descripcion
            ),
            '[]'::jsonb
        ),
        COUNT(*)
    INTO v_giros_eventuales, v_total_giros
    FROM comun.c_giros g
    WHERE g.tipo = 'E'
        AND g.vigente = 'V'
        AND (v_tipo_permiso IS NULL OR g.clasificacion = v_tipo_permiso);

    -- Obtener requisitos comunes para permisos eventuales
    -- Buscamos requisitos que se repiten en múltiples giros eventuales
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'req', req_info.req,
                'descripcion', req_info.descripcion,
                'detalle', CASE
                    WHEN v_incluir_desc THEN req_info.requisitos
                    ELSE NULL
                END,
                'giros_aplicables', req_info.num_giros,
                'es_comun', CASE
                    WHEN req_info.num_giros > 1 THEN true
                    ELSE false
                END
            )
            ORDER BY req_info.num_giros DESC, req_info.req
        ),
        '[]'::jsonb
    ) INTO v_requisitos_comunes
    FROM (
        SELECT
            cgr.req,
            cgr.descripcion,
            cgr.requisitos,
            COUNT(DISTINCT gr.id_giro) as num_giros
        FROM comun.c_girosreq cgr
        INNER JOIN comun.giro_req gr ON gr.req = cgr.req
        INNER JOIN comun.c_giros g ON g.id_giro = gr.id_giro
        WHERE g.tipo = 'E'
            AND g.vigente = 'V'
            AND (cgr.vigente IS NULL OR cgr.vigente = 'V')
            AND (v_tipo_permiso IS NULL OR g.clasificacion = v_tipo_permiso)
        GROUP BY cgr.req, cgr.descripcion, cgr.requisitos
    ) req_info;

    -- Construir resultado del reporte
    v_resultado := jsonb_build_object(
        'success', true,
        'message', 'Reporte de permisos eventuales generado exitosamente',
        'data', jsonb_build_object(
            'reporte', jsonb_build_object(
                'titulo', COALESCE(
                    v_titulo,
                    'Requisitos para Permisos Eventuales' ||
                    CASE WHEN v_periodo IS NOT NULL THEN ' - ' || v_periodo ELSE '' END
                ),
                'formato', v_formato,
                'fecha_generacion', v_fecha_reporte,
                'tipo_permiso', COALESCE(v_tipo_permiso, 'TODOS'),
                'periodo', v_periodo,
                'giros_eventuales', jsonb_build_object(
                    'listado', v_giros_eventuales,
                    'total', v_total_giros
                ),
                'requisitos', jsonb_build_object(
                    'comunes', COALESCE(
                        (
                            SELECT jsonb_agg(r)
                            FROM jsonb_array_elements(v_requisitos_comunes) r
                            WHERE (r->>'es_comun')::boolean = true
                        ),
                        '[]'::jsonb
                    ),
                    'especificos', COALESCE(
                        (
                            SELECT jsonb_agg(r)
                            FROM jsonb_array_elements(v_requisitos_comunes) r
                            WHERE (r->>'es_comun')::boolean = false
                        ),
                        '[]'::jsonb
                    ),
                    'todos', v_requisitos_comunes
                ),
                'incluye_descripciones', v_incluir_desc,
                'estadisticas', jsonb_build_object(
                    'total_giros', v_total_giros,
                    'total_requisitos', jsonb_array_length(v_requisitos_comunes),
                    'requisitos_comunes', (
                        SELECT COUNT(*)
                        FROM jsonb_array_elements(v_requisitos_comunes) r
                        WHERE (r->>'es_comun')::boolean = true
                    ),
                    'requisitos_especificos', (
                        SELECT COUNT(*)
                        FROM jsonb_array_elements(v_requisitos_comunes) r
                        WHERE (r->>'es_comun')::boolean = false
                    )
                )
            ),
            'metadata', jsonb_build_object(
                'generado_por', 'Sistema de Padrón de Licencias',
                'modulo', 'repdoc - Reporte de Permisos Eventuales',
                'fecha', v_fecha_reporte,
                'formato_salida', v_formato
            )
        )
    );

    RETURN v_resultado;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Error al generar reporte de permisos eventuales: ' || SQLERRM,
            'data', NULL,
            'error_code', SQLSTATE
        );
END;
$$;

COMMENT ON FUNCTION comun.repdoc_print_permisos_eventuales(JSONB) IS
'Genera reporte completo de requisitos para permisos eventuales, identificando requisitos comunes y específicos entre diferentes tipos de permisos';

\echo 'SP 4/4 creado: repdoc_print_permisos_eventuales'

-- ============================================
-- PERMISOS
-- ============================================

-- Otorgar permisos de ejecución al rol de aplicación
-- GRANT EXECUTE ON FUNCTION comun.repdoc_get_giros(JSONB) TO app_padron_licencias;
-- GRANT EXECUTE ON FUNCTION comun.repdoc_get_requisitos_by_giro(JSONB) TO app_padron_licencias;
-- GRANT EXECUTE ON FUNCTION comun.repdoc_print_requisitos(JSONB) TO app_padron_licencias;
-- GRANT EXECUTE ON FUNCTION comun.repdoc_print_permisos_eventuales(JSONB) TO app_padron_licencias;

\echo '============================================'
\echo 'Despliegue completado exitosamente'
\echo '============================================'
\echo 'Resumen:'
\echo '  - Schema: comun'
\echo '  - Total SPs implementados: 4'
\echo '  - SP 1: repdoc_get_giros (Consulta giros con filtros)'
\echo '  - SP 2: repdoc_get_requisitos_by_giro (Requisitos por giro)'
\echo '  - SP 3: repdoc_print_requisitos (Reporte de requisitos)'
\echo '  - SP 4: repdoc_print_permisos_eventuales (Reporte permisos eventuales)'
\echo '============================================'
\echo 'NOTA: Ajustar permisos según usuario de BD'
\echo '============================================'

-- ============================================
-- TABLAS UTILIZADAS (REFERENCIA)
-- ============================================
--
-- comun.c_giros: Catálogo de giros
--   - id_giro (PK)
--   - descripcion
--   - clasificacion
--   - tipo (L=Licencia, A=Anuncio, E=Eventual)
--   - caracteristicas
--   - vigente (V=Vigente, N=No vigente)
--   - fecha_creacion
--
-- comun.c_girosreq: Catálogo de requisitos
--   - req (PK)
--   - descripcion
--   - requisitos (detalle del requisito)
--   - vigente
--
-- comun.giro_req: Relación giros-requisitos
--   - id_giro (FK a c_giros)
--   - req (FK a c_girosreq)
--   - obligatorio
--   - orden
--
-- ============================================
-- FIN DEL SCRIPT
-- ============================================
