-- =====================================================================================
-- STORED PROCEDURES: girosVigentesCteXgirofrm
-- Módulo: padron_licencias
-- Descripción: Reporte de giros vigentes por cliente y tipo de giro
-- Fecha de generación: 2025-11-21
-- Generado por: Claude AI Assistant
-- =====================================================================================
-- Componente Vue: girosVigentesCteXgirofrm
-- Funcionalidad: Genera listado para reportes con filtros múltiples
-- =====================================================================================

-- ===================================================================================
-- LIMPIEZA PREVIA
-- ===================================================================================
DROP FUNCTION IF EXISTS comun.sp_giros_vigentes_cte_x_giro(INTEGER, VARCHAR, DATE, DATE, BOOLEAN, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS comun.girosVigentesCteXgirofrm_sp_get_catalogo_giros(INTEGER, VARCHAR, DATE, DATE, BOOLEAN, INTEGER) CASCADE;

-- ===================================================================================
-- SP 1: sp_giros_vigentes_cte_x_giro
-- Descripción: Reporte de giros vigentes con filtros múltiples
-- Parámetros:
--   p_id_giro: Filtrar por giro específico (opcional)
--   p_tipo_giro: Filtrar por tipo L=Licencia, A=Anuncio, E=Eventual, etc. (opcional)
--   p_fecha_desde: Fecha inicio de vigencia (opcional)
--   p_fecha_hasta: Fecha fin de vigencia (opcional)
--   p_incluir_bajas: Incluir licencias dadas de baja (default FALSE)
--   p_limit: Límite de registros (default 1000)
-- Retorna: Listado de licencias con información de giro y propietario
-- ===================================================================================
CREATE OR REPLACE FUNCTION comun.sp_giros_vigentes_cte_x_giro(
    p_id_giro INTEGER DEFAULT NULL,
    p_tipo_giro VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_incluir_bajas BOOLEAN DEFAULT FALSE,
    p_limit INTEGER DEFAULT 1000
)
RETURNS TABLE(
    licencia_id INTEGER,
    numero_licencia VARCHAR,
    id_giro INTEGER,
    descripcion_giro VARCHAR,
    tipo_giro VARCHAR,
    clasificacion VARCHAR,
    propietario VARCHAR,
    razon_social VARCHAR,
    domicilio_completo VARCHAR,
    colonia VARCHAR,
    fecha_alta DATE,
    fecha_vencimiento DATE,
    vigente VARCHAR,
    estado VARCHAR,
    total_adeudo NUMERIC(12,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_sql TEXT;
    v_where TEXT := '';
    v_limit_val INTEGER;
BEGIN
    -- =========================================================================
    -- Validar y establecer límite máximo
    -- =========================================================================
    v_limit_val := LEAST(COALESCE(p_limit, 1000), 10000);

    -- =========================================================================
    -- Construir consulta base
    -- =========================================================================
    v_sql := '
        SELECT
            l.id_licencia::INTEGER AS licencia_id,
            COALESCE(l.numero_licencia, '''')::VARCHAR AS numero_licencia,
            l.id_giro::INTEGER AS id_giro,
            COALESCE(g.descripcion, ''Sin descripción'')::VARCHAR AS descripcion_giro,
            COALESCE(g.tipo, ''N/D'')::VARCHAR AS tipo_giro,
            COALESCE(g.clasificacion, ''Sin clasificación'')::VARCHAR AS clasificacion,
            COALESCE(l.propietario, '''')::VARCHAR AS propietario,
            COALESCE(l.razon_social, '''')::VARCHAR AS razon_social,
            TRIM(CONCAT_WS('' '',
                COALESCE(l.calle, ''''),
                CASE WHEN l.numero IS NOT NULL AND l.numero != '''' THEN ''#'' || l.numero ELSE '''' END,
                CASE WHEN l.colonia IS NOT NULL AND l.colonia != '''' THEN '', '' || l.colonia ELSE '''' END
            ))::VARCHAR AS domicilio_completo,
            COALESCE(l.colonia, '''')::VARCHAR AS colonia,
            l.fecha_alta::DATE AS fecha_alta,
            l.fecha_vencimiento::DATE AS fecha_vencimiento,
            COALESCE(l.vigente, ''N'')::VARCHAR AS vigente,
            CASE
                WHEN l.vigente = ''V'' THEN ''Vigente''
                WHEN l.vigente = ''C'' THEN ''Cancelada''
                WHEN l.vigente = ''B'' THEN ''Baja''
                WHEN l.vigente = ''S'' THEN ''Suspendida''
                ELSE ''Desconocido''
            END::VARCHAR AS estado,
            COALESCE(l.saldo, 0.00)::NUMERIC(12,2) AS total_adeudo
        FROM comun.licencias l
        INNER JOIN comun.c_giros g ON l.id_giro = g.id_giro
        WHERE 1=1
    ';

    -- =========================================================================
    -- Construir condiciones WHERE dinámicas
    -- =========================================================================

    -- Filtro por estado de vigencia
    IF p_incluir_bajas THEN
        -- Incluir vigentes y bajas/canceladas
        v_where := v_where || ' AND l.vigente IN (''V'', ''C'', ''B'')';
    ELSE
        -- Solo vigentes
        v_where := v_where || ' AND l.vigente = ''V''';
    END IF;

    -- Filtro por giro específico
    IF p_id_giro IS NOT NULL THEN
        v_where := v_where || ' AND l.id_giro = ' || p_id_giro::TEXT;
    END IF;

    -- Filtro por tipo de giro
    IF p_tipo_giro IS NOT NULL AND p_tipo_giro != '' THEN
        v_where := v_where || ' AND g.tipo ILIKE ' || quote_literal('%' || p_tipo_giro || '%');
    END IF;

    -- Filtro por fecha desde (fecha de alta)
    IF p_fecha_desde IS NOT NULL THEN
        v_where := v_where || ' AND l.fecha_alta >= ' || quote_literal(p_fecha_desde::TEXT);
    END IF;

    -- Filtro por fecha hasta (fecha de alta)
    IF p_fecha_hasta IS NOT NULL THEN
        v_where := v_where || ' AND l.fecha_alta <= ' || quote_literal(p_fecha_hasta::TEXT);
    END IF;

    -- =========================================================================
    -- Agregar condiciones WHERE, ordenamiento y límite
    -- =========================================================================
    v_sql := v_sql || v_where || '
        ORDER BY g.descripcion ASC, l.numero_licencia ASC
        LIMIT ' || v_limit_val::TEXT;

    -- =========================================================================
    -- Ejecutar consulta dinámica
    -- =========================================================================
    RETURN QUERY EXECUTE v_sql;

EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, retornar conjunto vacío y registrar
        RAISE WARNING 'Error en sp_giros_vigentes_cte_x_giro: % - %', SQLSTATE, SQLERRM;
        RETURN;
END;
$$;

-- ===================================================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- ===================================================================================
COMMENT ON FUNCTION comun.sp_giros_vigentes_cte_x_giro(INTEGER, VARCHAR, DATE, DATE, BOOLEAN, INTEGER) IS
'Reporte de giros vigentes por cliente y tipo de giro.
Genera listado para reportes con filtros múltiples.

Parámetros:
- p_id_giro: ID del giro específico a filtrar (NULL para todos)
- p_tipo_giro: Tipo de giro (L=Licencia, A=Anuncio, E=Eventual)
- p_fecha_desde: Fecha inicio del rango de alta
- p_fecha_hasta: Fecha fin del rango de alta
- p_incluir_bajas: TRUE para incluir licencias canceladas/bajas
- p_limit: Máximo de registros a retornar (default 1000, max 10000)

Ejemplo de uso:
  -- Todos los giros vigentes
  SELECT * FROM comun.sp_giros_vigentes_cte_x_giro();

  -- Filtrar por giro específico
  SELECT * FROM comun.sp_giros_vigentes_cte_x_giro(p_id_giro := 123);

  -- Licencias de tipo "L" en un rango de fechas
  SELECT * FROM comun.sp_giros_vigentes_cte_x_giro(
    p_tipo_giro := ''L'',
    p_fecha_desde := ''2024-01-01'',
    p_fecha_hasta := ''2024-12-31''
  );

  -- Incluir bajas con límite personalizado
  SELECT * FROM comun.sp_giros_vigentes_cte_x_giro(
    p_incluir_bajas := TRUE,
    p_limit := 5000
  );

Autor: Claude AI Assistant
Fecha: 2025-11-21
Módulo: padron_licencias
Componente: girosVigentesCteXgirofrm';

-- ===================================================================================
-- ALIAS PARA COMPATIBILIDAD CON FRONTEND
-- ===================================================================================
-- El frontend puede llamar con el nombre del componente Vue
CREATE OR REPLACE FUNCTION comun.girosVigentesCteXgirofrm_sp_get_catalogo_giros(
    p_id_giro INTEGER DEFAULT NULL,
    p_tipo_giro VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_incluir_bajas BOOLEAN DEFAULT FALSE,
    p_limit INTEGER DEFAULT 1000
)
RETURNS TABLE(
    licencia_id INTEGER,
    numero_licencia VARCHAR,
    id_giro INTEGER,
    descripcion_giro VARCHAR,
    tipo_giro VARCHAR,
    clasificacion VARCHAR,
    propietario VARCHAR,
    razon_social VARCHAR,
    domicilio_completo VARCHAR,
    colonia VARCHAR,
    fecha_alta DATE,
    fecha_vencimiento DATE,
    vigente VARCHAR,
    estado VARCHAR,
    total_adeudo NUMERIC(12,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- =========================================================================
    -- Wrapper que llama a la función principal
    -- Mantiene compatibilidad con el naming convention del frontend Vue
    -- =========================================================================
    RETURN QUERY
    SELECT * FROM comun.sp_giros_vigentes_cte_x_giro(
        p_id_giro,
        p_tipo_giro,
        p_fecha_desde,
        p_fecha_hasta,
        p_incluir_bajas,
        p_limit
    );
END;
$$;

COMMENT ON FUNCTION comun.girosVigentesCteXgirofrm_sp_get_catalogo_giros(INTEGER, VARCHAR, DATE, DATE, BOOLEAN, INTEGER) IS
'Alias de compatibilidad para el componente Vue girosVigentesCteXgirofrm.
Llama internamente a comun.sp_giros_vigentes_cte_x_giro()';

-- ===================================================================================
-- GRANTS Y PERMISOS
-- ===================================================================================
GRANT EXECUTE ON FUNCTION comun.sp_giros_vigentes_cte_x_giro(INTEGER, VARCHAR, DATE, DATE, BOOLEAN, INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.girosVigentesCteXgirofrm_sp_get_catalogo_giros(INTEGER, VARCHAR, DATE, DATE, BOOLEAN, INTEGER) TO PUBLIC;

-- ===================================================================================
-- VERIFICACIÓN DE IMPLEMENTACIÓN
-- ===================================================================================
DO $$
DECLARE
    v_count INTEGER := 0;
    v_function_name TEXT;
    v_functions TEXT[] := ARRAY[
        'sp_giros_vigentes_cte_x_giro',
        'girosvigentesctexgirofrm_sp_get_catalogo_giros'
    ];
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'VERIFICACIÓN DE STORED PROCEDURES - girosVigentesCteXgirofrm';
    RAISE NOTICE '=====================================================';

    FOREACH v_function_name IN ARRAY v_functions
    LOOP
        IF EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'comun'
            AND p.proname = v_function_name
        ) THEN
            v_count := v_count + 1;
            RAISE NOTICE '[OK] comun.% - Creada correctamente', v_function_name;
        ELSE
            RAISE NOTICE '[ERROR] comun.% - No se pudo crear', v_function_name;
        END IF;
    END LOOP;

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE 'Total funciones verificadas: %/2', v_count;
    RAISE NOTICE '=====================================================';

    IF v_count = 2 THEN
        RAISE NOTICE 'RESULTADO: TODAS LAS FUNCIONES IMPLEMENTADAS CORRECTAMENTE';
    ELSE
        RAISE WARNING 'RESULTADO: ALGUNAS FUNCIONES NO SE CREARON';
    END IF;
END $$;

-- ===================================================================================
-- FIN DEL SCRIPT
-- ===================================================================================
-- Archivo: GIROSVIGENTESCTEXGIROFRM_all_procedures_IMPLEMENTED.sql
-- Módulo: padron_licencias
-- Componente: girosVigentesCteXgirofrm
-- SPs implementados:
--   1. comun.sp_giros_vigentes_cte_x_giro - Función principal
--   2. comun.girosVigentesCteXgirofrm_sp_get_catalogo_giros - Alias compatibilidad
-- ===================================================================================
