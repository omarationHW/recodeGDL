-- =====================================================================================
-- REPSUSPENDIDASFRM - Stored Procedures Completos
-- Módulo: padron_licencias
-- Componente: Reporte de Licencias Suspendidas
-- Fecha: 2025-11-21
-- =====================================================================================

-- =====================================================================================
-- PARTE 1: TABLA AUXILIAR - CATÁLOGO DE TIPOS DE SUSPENSIÓN
-- =====================================================================================

-- Crear tabla de tipos de suspensión si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'comun'
        AND table_name = 'c_tipos_suspension'
    ) THEN
        CREATE TABLE comun.c_tipos_suspension (
            id SERIAL PRIMARY KEY,
            descripcion VARCHAR(200) NOT NULL,
            activo BOOLEAN DEFAULT TRUE,
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Insertar tipos de suspensión comunes
        INSERT INTO comun.c_tipos_suspension (id, descripcion) VALUES
            (1, 'SUSPENSIÓN POR ADEUDO FISCAL'),
            (2, 'SUSPENSIÓN POR INCUMPLIMIENTO DE REQUISITOS'),
            (3, 'SUSPENSIÓN POR DENUNCIA CIUDADANA'),
            (4, 'SUSPENSIÓN POR OPERATIVO DE INSPECCIÓN'),
            (5, 'SUSPENSIÓN TEMPORAL VOLUNTARIA'),
            (6, 'SUSPENSIÓN POR CAMBIO DE GIRO NO AUTORIZADO'),
            (7, 'SUSPENSIÓN POR FALTA DE PERMISOS ADICIONALES'),
            (8, 'SUSPENSIÓN POR ORDEN JUDICIAL'),
            (9, 'SUSPENSIÓN POR INCUMPLIMIENTO AMBIENTAL'),
            (10, 'CANCELACIÓN DEFINITIVA'),
            (99, 'OTRO MOTIVO');

        RAISE NOTICE 'Tabla c_tipos_suspension creada e inicializada correctamente';
    ELSE
        RAISE NOTICE 'Tabla c_tipos_suspension ya existe';
    END IF;
END $$;

-- =====================================================================================
-- PARTE 2: SP AUXILIAR - CATÁLOGO DE TIPOS DE SUSPENSIÓN
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.repsuspendidasfrm_sp_get_tipos_suspension();

CREATE OR REPLACE FUNCTION comun.repsuspendidasfrm_sp_get_tipos_suspension()
RETURNS TABLE (
    id INTEGER,
    descripcion VARCHAR(200)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
/*
    Función: repsuspendidasfrm_sp_get_tipos_suspension
    Descripción: Obtiene el catálogo de tipos de suspensión activos
    Módulo: padron_licencias
    Componente: REPSUSPENDIDASFRM

    Retorna:
        - id: Identificador del tipo de suspensión
        - descripcion: Descripción del tipo de suspensión

    Ejemplo de uso:
        SELECT * FROM comun.repsuspendidasfrm_sp_get_tipos_suspension();
*/
BEGIN
    RETURN QUERY
    SELECT
        ts.id::INTEGER,
        ts.descripcion::VARCHAR(200)
    FROM comun.c_tipos_suspension ts
    WHERE ts.activo = TRUE
    ORDER BY ts.id;

EXCEPTION
    WHEN undefined_table THEN
        -- Si la tabla no existe, retornar valores por defecto
        RETURN QUERY
        SELECT 0::INTEGER, 'TODOS LOS TIPOS'::VARCHAR(200)
        UNION ALL
        SELECT 1::INTEGER, 'SUSPENSIÓN POR ADEUDO FISCAL'::VARCHAR(200)
        UNION ALL
        SELECT 2::INTEGER, 'SUSPENSIÓN POR INCUMPLIMIENTO'::VARCHAR(200)
        UNION ALL
        SELECT 10::INTEGER, 'CANCELACIÓN DEFINITIVA'::VARCHAR(200);

    WHEN OTHERS THEN
        RAISE WARNING 'Error en repsuspendidasfrm_sp_get_tipos_suspension: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.repsuspendidasfrm_sp_get_tipos_suspension() IS
'Obtiene el catálogo de tipos de suspensión para el reporte de licencias suspendidas';

-- =====================================================================================
-- PARTE 3: SP AUXILIAR - ESTADÍSTICAS DE LICENCIAS SUSPENDIDAS
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.repsuspendidasfrm_sp_get_estadisticas_suspendidas(INTEGER);

CREATE OR REPLACE FUNCTION comun.repsuspendidasfrm_sp_get_estadisticas_suspendidas(
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    total_suspendidas BIGINT,
    total_canceladas BIGINT,
    por_tipo JSONB,
    por_zona JSONB,
    por_mes JSONB,
    promedio_dias_suspension NUMERIC,
    ultimo_periodo_info JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
/*
    Función: repsuspendidasfrm_sp_get_estadisticas_suspendidas
    Descripción: Genera estadísticas resumidas de licencias suspendidas y canceladas
    Módulo: padron_licencias
    Componente: REPSUSPENDIDASFRM

    Parámetros:
        - p_anio: Año a consultar (NULL = todos los años)

    Retorna:
        - total_suspendidas: Total de licencias suspendidas
        - total_canceladas: Total de licencias canceladas
        - por_tipo: JSON con conteo por tipo de suspensión
        - por_zona: JSON con conteo por zona
        - por_mes: JSON con conteo por mes
        - promedio_dias_suspension: Promedio de días de suspensión
        - ultimo_periodo_info: Información del último período

    Ejemplo de uso:
        SELECT * FROM comun.repsuspendidasfrm_sp_get_estadisticas_suspendidas(2024);
        SELECT * FROM comun.repsuspendidasfrm_sp_get_estadisticas_suspendidas(); -- Todos los años
*/
DECLARE
    v_total_suspendidas BIGINT := 0;
    v_total_canceladas BIGINT := 0;
    v_por_tipo JSONB := '[]'::JSONB;
    v_por_zona JSONB := '[]'::JSONB;
    v_por_mes JSONB := '[]'::JSONB;
    v_promedio_dias NUMERIC := 0;
    v_ultimo_periodo JSONB := '{}'::JSONB;
    v_anio_filtro INTEGER;
BEGIN
    -- Determinar el año de filtro
    v_anio_filtro := COALESCE(p_anio, 0);

    -- Contar total de suspendidas (vigente = 'S')
    SELECT COUNT(*)
    INTO v_total_suspendidas
    FROM comun.licencias l
    WHERE l.vigente = 'S'
    AND (v_anio_filtro = 0 OR EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)) = v_anio_filtro);

    -- Contar total de canceladas (vigente = 'X')
    SELECT COUNT(*)
    INTO v_total_canceladas
    FROM comun.licencias l
    WHERE l.vigente = 'X'
    AND (v_anio_filtro = 0 OR EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)) = v_anio_filtro);

    -- Estadísticas por tipo de suspensión
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'tipo_id', tipo_id,
            'tipo_descripcion', tipo_desc,
            'cantidad', cantidad,
            'porcentaje', ROUND((cantidad::NUMERIC / NULLIF(total, 0)) * 100, 2)
        )
    ), '[]'::JSONB)
    INTO v_por_tipo
    FROM (
        SELECT
            COALESCE(l.tipo_suspension, 99) AS tipo_id,
            COALESCE(ts.descripcion, 'SIN CLASIFICAR') AS tipo_desc,
            COUNT(*) AS cantidad,
            SUM(COUNT(*)) OVER() AS total
        FROM comun.licencias l
        LEFT JOIN comun.c_tipos_suspension ts ON ts.id = l.tipo_suspension
        WHERE l.vigente IN ('S', 'X')
        AND (v_anio_filtro = 0 OR EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)) = v_anio_filtro)
        GROUP BY COALESCE(l.tipo_suspension, 99), COALESCE(ts.descripcion, 'SIN CLASIFICAR')
        ORDER BY cantidad DESC
    ) sub;

    -- Estadísticas por zona
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'zona', zona_nombre,
            'cantidad', cantidad,
            'porcentaje', ROUND((cantidad::NUMERIC / NULLIF(total, 0)) * 100, 2)
        )
    ), '[]'::JSONB)
    INTO v_por_zona
    FROM (
        SELECT
            COALESCE(l.zona::TEXT, 'SIN ZONA') AS zona_nombre,
            COUNT(*) AS cantidad,
            SUM(COUNT(*)) OVER() AS total
        FROM comun.licencias l
        WHERE l.vigente IN ('S', 'X')
        AND (v_anio_filtro = 0 OR EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)) = v_anio_filtro)
        GROUP BY COALESCE(l.zona::TEXT, 'SIN ZONA')
        ORDER BY cantidad DESC
        LIMIT 20
    ) sub;

    -- Estadísticas por mes (últimos 12 meses o del año especificado)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'anio', anio,
            'mes', mes,
            'mes_nombre', mes_nombre,
            'suspendidas', suspendidas,
            'canceladas', canceladas,
            'total', suspendidas + canceladas
        )
        ORDER BY anio DESC, mes DESC
    ), '[]'::JSONB)
    INTO v_por_mes
    FROM (
        SELECT
            EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion))::INTEGER AS anio,
            EXTRACT(MONTH FROM COALESCE(l.fecha_suspension, l.fecha_modificacion))::INTEGER AS mes,
            TO_CHAR(COALESCE(l.fecha_suspension, l.fecha_modificacion), 'TMMonth') AS mes_nombre,
            COUNT(*) FILTER (WHERE l.vigente = 'S') AS suspendidas,
            COUNT(*) FILTER (WHERE l.vigente = 'X') AS canceladas
        FROM comun.licencias l
        WHERE l.vigente IN ('S', 'X')
        AND (v_anio_filtro = 0 OR EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)) = v_anio_filtro)
        AND COALESCE(l.fecha_suspension, l.fecha_modificacion) IS NOT NULL
        GROUP BY
            EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)),
            EXTRACT(MONTH FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)),
            TO_CHAR(COALESCE(l.fecha_suspension, l.fecha_modificacion), 'TMMonth')
        ORDER BY anio DESC, mes DESC
        LIMIT 12
    ) sub;

    -- Calcular promedio de días de suspensión (si hay fecha de reactivación)
    SELECT COALESCE(AVG(
        CASE
            WHEN l.fecha_reactivacion IS NOT NULL AND l.fecha_suspension IS NOT NULL
            THEN EXTRACT(DAY FROM (l.fecha_reactivacion - l.fecha_suspension))
            ELSE NULL
        END
    ), 0)
    INTO v_promedio_dias
    FROM comun.licencias l
    WHERE l.vigente IN ('S', 'X')
    AND (v_anio_filtro = 0 OR EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)) = v_anio_filtro);

    -- Información del último período
    SELECT jsonb_build_object(
        'ultima_suspension', (
            SELECT MAX(fecha_suspension)
            FROM comun.licencias
            WHERE vigente IN ('S', 'X')
            AND (v_anio_filtro = 0 OR EXTRACT(YEAR FROM fecha_suspension) = v_anio_filtro)
        ),
        'anio_consultado', CASE WHEN v_anio_filtro = 0 THEN 'TODOS' ELSE v_anio_filtro::TEXT END,
        'fecha_generacion', CURRENT_TIMESTAMP,
        'total_registros', v_total_suspendidas + v_total_canceladas
    )
    INTO v_ultimo_periodo;

    -- Retornar resultados
    RETURN QUERY
    SELECT
        v_total_suspendidas,
        v_total_canceladas,
        v_por_tipo,
        v_por_zona,
        v_por_mes,
        ROUND(v_promedio_dias, 2),
        v_ultimo_periodo;

EXCEPTION
    WHEN undefined_table THEN
        RAISE WARNING 'Tabla de licencias no encontrada';
        RETURN QUERY
        SELECT
            0::BIGINT,
            0::BIGINT,
            '[]'::JSONB,
            '[]'::JSONB,
            '[]'::JSONB,
            0::NUMERIC,
            jsonb_build_object('error', 'Tabla de licencias no encontrada')::JSONB;

    WHEN OTHERS THEN
        RAISE WARNING 'Error en repsuspendidasfrm_sp_get_estadisticas_suspendidas: %', SQLERRM;
        RETURN QUERY
        SELECT
            0::BIGINT,
            0::BIGINT,
            '[]'::JSONB,
            '[]'::JSONB,
            '[]'::JSONB,
            0::NUMERIC,
            jsonb_build_object('error', SQLERRM)::JSONB;
END;
$$;

COMMENT ON FUNCTION comun.repsuspendidasfrm_sp_get_estadisticas_suspendidas(INTEGER) IS
'Genera estadísticas resumidas de licencias suspendidas y canceladas con agrupaciones por tipo, zona y mes';

-- =====================================================================================
-- PARTE 4: SP PRINCIPAL - REPORTE DE LICENCIAS SUSPENDIDAS
-- =====================================================================================

DROP FUNCTION IF EXISTS comun.repsuspendidasfrm_sp_report_licencias_suspendidas(INTEGER, DATE, DATE, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
    p_anio INTEGER DEFAULT 0,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_tipo_suspension INTEGER DEFAULT 0,
    p_zona INTEGER DEFAULT NULL,
    p_limit INTEGER DEFAULT 1000
)
RETURNS TABLE (
    id_licencia INTEGER,
    numero_licencia VARCHAR(50),
    empresa_id INTEGER,
    recaudadora VARCHAR(100),
    id_giro INTEGER,
    descripcion_giro VARCHAR(500),
    x NUMERIC,
    y NUMERIC,
    zona INTEGER,
    subzona INTEGER,
    tipo_registro VARCHAR(50),
    cvecuenta VARCHAR(50),
    fecha_otorgamiento DATE,
    propietario VARCHAR(200),
    primer_ap VARCHAR(100),
    segundo_ap VARCHAR(100),
    rfc VARCHAR(20),
    curp VARCHAR(20),
    domicilio_propietario VARCHAR(500),
    numext VARCHAR(20),
    numint VARCHAR(20),
    colonia VARCHAR(200),
    telefono VARCHAR(50),
    domicilio_negocio_completo VARCHAR(1000),
    razon_social VARCHAR(500),
    nombre_comercial VARCHAR(500),
    fecha_suspension DATE,
    motivo_suspension VARCHAR(1000),
    tipo_suspension_id INTEGER,
    tipo_suspension_desc VARCHAR(200),
    usuario_suspendio VARCHAR(100),
    vigente VARCHAR(1),
    estado VARCHAR(50),
    dias_suspendido INTEGER,
    fecha_reactivacion DATE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
/*
    Función: repsuspendidasfrm_sp_report_licencias_suspendidas
    Descripción: Genera reporte detallado de licencias suspendidas y canceladas
    Módulo: padron_licencias
    Componente: REPSUSPENDIDASFRM

    Parámetros:
        - p_anio: Año de suspensión a filtrar (0 = todos los años)
        - p_fecha_desde: Fecha inicial del rango de suspensión
        - p_fecha_hasta: Fecha final del rango de suspensión
        - p_tipo_suspension: Tipo de suspensión a filtrar (0 = todos)
        - p_zona: Zona a filtrar (NULL = todas)
        - p_limit: Límite de registros a retornar (default 1000)

    Retorna: 35 campos detallados de cada licencia suspendida

    Lógica:
        - Filtra licencias con vigente IN ('S', 'X')
        - S = Suspendida, X = Cancelada
        - Aplica filtros dinámicos según parámetros
        - Construye domicilios completos con CONCAT_WS
        - Calcula días de suspensión

    Ejemplo de uso:
        -- Todas las suspendidas
        SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas();

        -- Por año específico
        SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(2024);

        -- Por rango de fechas
        SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
            0, '2024-01-01', '2024-12-31'
        );

        -- Por tipo de suspensión
        SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
            0, NULL, NULL, 1
        );

        -- Por zona
        SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
            0, NULL, NULL, 0, 5
        );
*/
DECLARE
    v_sql TEXT;
    v_where TEXT := '';
    v_limit_value INTEGER;
BEGIN
    -- Validar y ajustar límite
    v_limit_value := LEAST(COALESCE(p_limit, 1000), 10000);

    -- Construir condiciones WHERE dinámicas

    -- Filtro por año
    IF p_anio IS NOT NULL AND p_anio > 0 THEN
        v_where := v_where || format(' AND EXTRACT(YEAR FROM COALESCE(l.fecha_suspension, l.fecha_modificacion)) = %s', p_anio);
    END IF;

    -- Filtro por rango de fechas
    IF p_fecha_desde IS NOT NULL THEN
        v_where := v_where || format(' AND COALESCE(l.fecha_suspension, l.fecha_modificacion) >= %L', p_fecha_desde);
    END IF;

    IF p_fecha_hasta IS NOT NULL THEN
        v_where := v_where || format(' AND COALESCE(l.fecha_suspension, l.fecha_modificacion) <= %L', p_fecha_hasta);
    END IF;

    -- Filtro por tipo de suspensión
    IF p_tipo_suspension IS NOT NULL AND p_tipo_suspension > 0 THEN
        v_where := v_where || format(' AND COALESCE(l.tipo_suspension, 0) = %s', p_tipo_suspension);
    END IF;

    -- Filtro por zona
    IF p_zona IS NOT NULL THEN
        v_where := v_where || format(' AND l.zona = %s', p_zona);
    END IF;

    -- Construir consulta principal
    v_sql := format($SQL$
        SELECT
            l.id_licencia::INTEGER,
            COALESCE(l.numero_licencia, l.id_licencia::TEXT)::VARCHAR(50) AS numero_licencia,
            COALESCE(l.empresa_id, 0)::INTEGER AS empresa_id,
            COALESCE(l.recaudadora, 'SIN ASIGNAR')::VARCHAR(100) AS recaudadora,
            COALESCE(l.id_giro, 0)::INTEGER AS id_giro,
            COALESCE(g.descripcion, 'SIN GIRO ASIGNADO')::VARCHAR(500) AS descripcion_giro,
            COALESCE(l.x, 0)::NUMERIC AS x,
            COALESCE(l.y, 0)::NUMERIC AS y,
            COALESCE(l.zona, 0)::INTEGER AS zona,
            COALESCE(l.subzona, 0)::INTEGER AS subzona,
            COALESCE(l.tipo_registro, 'ORDINARIA')::VARCHAR(50) AS tipo_registro,
            COALESCE(l.cvecuenta, '')::VARCHAR(50) AS cvecuenta,
            l.fecha_otorgamiento::DATE,

            -- Datos del propietario
            COALESCE(l.propietario, '')::VARCHAR(200) AS propietario,
            COALESCE(l.primer_ap, '')::VARCHAR(100) AS primer_ap,
            COALESCE(l.segundo_ap, '')::VARCHAR(100) AS segundo_ap,
            COALESCE(l.rfc, '')::VARCHAR(20) AS rfc,
            COALESCE(l.curp, '')::VARCHAR(20) AS curp,

            -- Domicilio del propietario
            COALESCE(
                CONCAT_WS(' ',
                    NULLIF(TRIM(l.calle_propietario), ''),
                    NULLIF(TRIM(l.numext_propietario), ''),
                    CASE WHEN NULLIF(TRIM(l.numint_propietario), '') IS NOT NULL
                         THEN 'INT. ' || l.numint_propietario
                         ELSE NULL
                    END
                ),
                ''
            )::VARCHAR(500) AS domicilio_propietario,
            COALESCE(l.numext, '')::VARCHAR(20) AS numext,
            COALESCE(l.numint, '')::VARCHAR(20) AS numint,
            COALESCE(l.colonia, '')::VARCHAR(200) AS colonia,
            COALESCE(l.telefono, '')::VARCHAR(50) AS telefono,

            -- Domicilio completo del negocio
            CONCAT_WS(', ',
                NULLIF(TRIM(CONCAT_WS(' ',
                    NULLIF(TRIM(l.calle), ''),
                    CASE WHEN NULLIF(TRIM(l.numext), '') IS NOT NULL
                         THEN 'No. ' || l.numext
                         ELSE NULL
                    END,
                    CASE WHEN NULLIF(TRIM(l.numint), '') IS NOT NULL
                         THEN 'Int. ' || l.numint
                         ELSE NULL
                    END
                )), ''),
                NULLIF(TRIM(l.colonia), ''),
                NULLIF(TRIM(l.codigo_postal), ''),
                'GUADALAJARA, JALISCO'
            )::VARCHAR(1000) AS domicilio_negocio_completo,

            -- Datos comerciales
            COALESCE(l.razon_social, '')::VARCHAR(500) AS razon_social,
            COALESCE(l.nombre_comercial, l.razon_social, '')::VARCHAR(500) AS nombre_comercial,

            -- Datos de suspensión
            COALESCE(l.fecha_suspension, l.fecha_modificacion)::DATE AS fecha_suspension,
            COALESCE(l.motivo_suspension, l.observaciones, 'NO ESPECIFICADO')::VARCHAR(1000) AS motivo_suspension,
            COALESCE(l.tipo_suspension, 99)::INTEGER AS tipo_suspension_id,
            COALESCE(ts.descripcion, 'SIN CLASIFICAR')::VARCHAR(200) AS tipo_suspension_desc,
            COALESCE(l.usuario_suspendio, l.usuario_modificacion, 'SISTEMA')::VARCHAR(100) AS usuario_suspendio,

            -- Estado
            l.vigente::VARCHAR(1),
            CASE l.vigente
                WHEN 'S' THEN 'SUSPENDIDA'
                WHEN 'X' THEN 'CANCELADA'
                ELSE 'OTRO'
            END::VARCHAR(50) AS estado,

            -- Cálculos adicionales
            CASE
                WHEN l.fecha_reactivacion IS NOT NULL AND l.fecha_suspension IS NOT NULL
                THEN EXTRACT(DAY FROM (l.fecha_reactivacion - l.fecha_suspension))::INTEGER
                WHEN l.fecha_suspension IS NOT NULL
                THEN EXTRACT(DAY FROM (CURRENT_DATE - l.fecha_suspension))::INTEGER
                ELSE 0
            END::INTEGER AS dias_suspendido,
            l.fecha_reactivacion::DATE

        FROM comun.licencias l
        LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
        LEFT JOIN comun.c_tipos_suspension ts ON ts.id = l.tipo_suspension
        WHERE l.vigente IN ('S', 'X')
        %s
        ORDER BY COALESCE(l.fecha_suspension, l.fecha_modificacion) DESC NULLS LAST
        LIMIT %s
    $SQL$, v_where, v_limit_value);

    -- Ejecutar consulta dinámica
    RETURN QUERY EXECUTE v_sql;

EXCEPTION
    WHEN undefined_column THEN
        -- Si faltan columnas, intentar con consulta simplificada
        RAISE WARNING 'Algunas columnas no existen, ejecutando consulta simplificada: %', SQLERRM;

        RETURN QUERY
        SELECT
            l.id_licencia::INTEGER,
            COALESCE(l.numero_licencia, l.id_licencia::TEXT)::VARCHAR(50),
            COALESCE(l.empresa_id, 0)::INTEGER,
            COALESCE(l.recaudadora, 'SIN ASIGNAR')::VARCHAR(100),
            COALESCE(l.id_giro, 0)::INTEGER,
            COALESCE(g.descripcion, 'SIN GIRO')::VARCHAR(500),
            0::NUMERIC, 0::NUMERIC,
            COALESCE(l.zona, 0)::INTEGER,
            0::INTEGER,
            'ORDINARIA'::VARCHAR(50),
            ''::VARCHAR(50),
            l.fecha_otorgamiento::DATE,
            COALESCE(l.propietario, '')::VARCHAR(200),
            ''::VARCHAR(100), ''::VARCHAR(100),
            COALESCE(l.rfc, '')::VARCHAR(20),
            ''::VARCHAR(20),
            ''::VARCHAR(500),
            ''::VARCHAR(20), ''::VARCHAR(20),
            COALESCE(l.colonia, '')::VARCHAR(200),
            ''::VARCHAR(50),
            COALESCE(l.calle, '')::VARCHAR(1000),
            COALESCE(l.razon_social, '')::VARCHAR(500),
            COALESCE(l.nombre_comercial, '')::VARCHAR(500),
            l.fecha_modificacion::DATE,
            'NO ESPECIFICADO'::VARCHAR(1000),
            0::INTEGER,
            'SIN CLASIFICAR'::VARCHAR(200),
            'SISTEMA'::VARCHAR(100),
            l.vigente::VARCHAR(1),
            CASE l.vigente WHEN 'S' THEN 'SUSPENDIDA' WHEN 'X' THEN 'CANCELADA' ELSE 'OTRO' END::VARCHAR(50),
            0::INTEGER,
            NULL::DATE
        FROM comun.licencias l
        LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
        WHERE l.vigente IN ('S', 'X')
        ORDER BY l.fecha_modificacion DESC NULLS LAST
        LIMIT v_limit_value;

    WHEN undefined_table THEN
        RAISE EXCEPTION 'Tabla de licencias no encontrada en schema comun';

    WHEN OTHERS THEN
        RAISE WARNING 'Error en repsuspendidasfrm_sp_report_licencias_suspendidas: %', SQLERRM;
        RAISE;
END;
$$;

COMMENT ON FUNCTION comun.repsuspendidasfrm_sp_report_licencias_suspendidas(INTEGER, DATE, DATE, INTEGER, INTEGER, INTEGER) IS
'Genera reporte completo de licencias suspendidas y canceladas con filtros dinámicos por año, fechas, tipo de suspensión y zona';

-- =====================================================================================
-- PARTE 5: VERIFICACIÓN DE INSTALACIÓN
-- =====================================================================================

DO $$
DECLARE
    v_count INTEGER;
    v_function_exists BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════════════════════';
    RAISE NOTICE 'VERIFICACIÓN DE STORED PROCEDURES - REPSUSPENDIDASFRM';
    RAISE NOTICE '═══════════════════════════════════════════════════════════════════';

    -- Verificar SP 1: Tipos de suspensión
    SELECT EXISTS(
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'repsuspendidasfrm_sp_get_tipos_suspension'
    ) INTO v_function_exists;

    IF v_function_exists THEN
        RAISE NOTICE '[OK] repsuspendidasfrm_sp_get_tipos_suspension';
    ELSE
        RAISE WARNING '[ERROR] repsuspendidasfrm_sp_get_tipos_suspension NO INSTALADO';
    END IF;

    -- Verificar SP 2: Estadísticas
    SELECT EXISTS(
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'repsuspendidasfrm_sp_get_estadisticas_suspendidas'
    ) INTO v_function_exists;

    IF v_function_exists THEN
        RAISE NOTICE '[OK] repsuspendidasfrm_sp_get_estadisticas_suspendidas';
    ELSE
        RAISE WARNING '[ERROR] repsuspendidasfrm_sp_get_estadisticas_suspendidas NO INSTALADO';
    END IF;

    -- Verificar SP 3: Reporte principal
    SELECT EXISTS(
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'repsuspendidasfrm_sp_report_licencias_suspendidas'
    ) INTO v_function_exists;

    IF v_function_exists THEN
        RAISE NOTICE '[OK] repsuspendidasfrm_sp_report_licencias_suspendidas';
    ELSE
        RAISE WARNING '[ERROR] repsuspendidasfrm_sp_report_licencias_suspendidas NO INSTALADO';
    END IF;

    -- Verificar tabla auxiliar
    SELECT EXISTS(
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'comun'
        AND table_name = 'c_tipos_suspension'
    ) INTO v_function_exists;

    IF v_function_exists THEN
        SELECT COUNT(*) INTO v_count FROM comun.c_tipos_suspension;
        RAISE NOTICE '[OK] Tabla c_tipos_suspension (% registros)', v_count;
    ELSE
        RAISE WARNING '[WARN] Tabla c_tipos_suspension no existe';
    END IF;

    RAISE NOTICE '═══════════════════════════════════════════════════════════════════';
    RAISE NOTICE 'INSTALACIÓN COMPLETADA - REPSUSPENDIDASFRM';
    RAISE NOTICE '═══════════════════════════════════════════════════════════════════';
    RAISE NOTICE '';
END $$;

-- =====================================================================================
-- PARTE 6: EJEMPLOS DE USO
-- =====================================================================================

/*
================================================================================
EJEMPLOS DE USO - REPSUSPENDIDASFRM
================================================================================

-- 1. Obtener catálogo de tipos de suspensión:
SELECT * FROM comun.repsuspendidasfrm_sp_get_tipos_suspension();

-- 2. Estadísticas generales (todos los años):
SELECT * FROM comun.repsuspendidasfrm_sp_get_estadisticas_suspendidas();

-- 3. Estadísticas de un año específico:
SELECT * FROM comun.repsuspendidasfrm_sp_get_estadisticas_suspendidas(2024);

-- 4. Reporte completo de suspendidas (últimas 1000):
SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas();

-- 5. Reporte filtrado por año:
SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(2024);

-- 6. Reporte filtrado por rango de fechas:
SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
    0,                    -- p_anio (0 = todos)
    '2024-01-01'::DATE,   -- p_fecha_desde
    '2024-12-31'::DATE,   -- p_fecha_hasta
    0,                    -- p_tipo_suspension (0 = todos)
    NULL,                 -- p_zona (NULL = todas)
    500                   -- p_limit
);

-- 7. Reporte filtrado por tipo de suspensión (adeudo fiscal = 1):
SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
    0, NULL, NULL, 1, NULL, 1000
);

-- 8. Reporte filtrado por zona:
SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
    0, NULL, NULL, 0, 5, 1000
);

-- 9. Combinación de filtros:
SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(
    2024,                 -- Solo 2024
    '2024-06-01'::DATE,   -- Desde junio
    '2024-12-31'::DATE,   -- Hasta diciembre
    1,                    -- Solo adeudo fiscal
    3,                    -- Solo zona 3
    200                   -- Máximo 200 registros
);

-- 10. Exportar a CSV (ejemplo desde psql):
\copy (SELECT * FROM comun.repsuspendidasfrm_sp_report_licencias_suspendidas(2024)) TO '/tmp/suspendidas_2024.csv' WITH CSV HEADER;

================================================================================
*/

-- =====================================================================================
-- FIN DEL SCRIPT
-- =====================================================================================
