-- =====================================================
-- STORED PROCEDURES: CATÁLOGO GIROS IMPORTES
-- Módulo: Licencias
-- Descripción: Gestión de costos para usuarios ingresos
-- Esquema: INFORMIX compatible
-- Fecha: 2025-09-29
-- =====================================================

-- 1. SP para obtener catálogo de giros con importes
CREATE OR REPLACE FUNCTION sp_catalogo_giros_importes_list(
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0,
    p_filtro TEXT DEFAULT '',
    p_categoria TEXT DEFAULT 'TODOS',
    p_estado_importe TEXT DEFAULT 'TODOS',
    p_vigencia TEXT DEFAULT 'TODOS'
)
RETURNS TABLE (
    id_giro INTEGER,
    codigo_giro VARCHAR(10),
    nombre_giro VARCHAR(200),
    descripcion_completa TEXT,
    categoria VARCHAR(50),
    subcategoria VARCHAR(80),
    importe_base DECIMAL(10,2),
    importe_zona_a DECIMAL(10,2),
    importe_zona_b DECIMAL(10,2),
    importe_zona_c DECIMAL(10,2),
    moneda VARCHAR(5),
    fecha_vigencia_inicio DATE,
    fecha_vigencia_fin DATE,
    estado_importe VARCHAR(20),
    usuario_modificacion VARCHAR(20),
    fecha_modificacion TIMESTAMP,
    observaciones TEXT,
    dias_hasta_vencimiento INTEGER,
    total_count INTEGER
) AS $$
DECLARE
    total_records INTEGER;
BEGIN
    -- Obtener el total de registros
    SELECT COUNT(*) INTO total_records
    FROM catalogo_giros cg
    LEFT JOIN importes_giros ig ON cg.id_giro = ig.id_giro
    WHERE (p_filtro = '' OR
           LOWER(cg.nombre_giro) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(cg.codigo_giro) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(cg.categoria) LIKE '%' || LOWER(p_filtro) || '%')
    AND (p_categoria = 'TODOS' OR LOWER(cg.categoria) = LOWER(p_categoria))
    AND (p_estado_importe = 'TODOS' OR
         (p_estado_importe = 'ASIGNADO' AND ig.importe_base IS NOT NULL) OR
         (p_estado_importe = 'PENDIENTE' AND ig.importe_base IS NULL))
    AND (p_vigencia = 'TODOS' OR
         (p_vigencia = 'VIGENTE' AND COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) > CURRENT_DATE) OR
         (p_vigencia = 'PROXIMO_VENCER' AND COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'))
    AND COALESCE(cg.activo, 'S') = 'S';

    -- Retornar datos paginados
    RETURN QUERY
    SELECT
        cg.id_giro,
        cg.codigo_giro,
        cg.nombre_giro,
        COALESCE(cg.descripcion_completa, '') as descripcion_completa,
        COALESCE(cg.categoria, 'SIN_CATEGORIA') as categoria,
        COALESCE(cg.subcategoria, '') as subcategoria,
        COALESCE(ig.importe_base, 0.00) as importe_base,
        COALESCE(ig.importe_zona_a, 0.00) as importe_zona_a,
        COALESCE(ig.importe_zona_b, 0.00) as importe_zona_b,
        COALESCE(ig.importe_zona_c, 0.00) as importe_zona_c,
        COALESCE(ig.moneda, 'MXN') as moneda,
        COALESCE(ig.fecha_vigencia_inicio, CURRENT_DATE) as fecha_vigencia_inicio,
        COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) as fecha_vigencia_fin,
        CASE
            WHEN ig.importe_base IS NULL THEN 'PENDIENTE'
            WHEN COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) <= CURRENT_DATE THEN 'VENCIDO'
            WHEN COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days' THEN 'PROXIMO_VENCER'
            ELSE 'VIGENTE'
        END as estado_importe,
        COALESCE(ig.usuario_modificacion, '') as usuario_modificacion,
        COALESCE(ig.fecha_modificacion, CURRENT_TIMESTAMP) as fecha_modificacion,
        COALESCE(ig.observaciones, '') as observaciones,
        CASE
            WHEN ig.fecha_vigencia_fin IS NULL THEN -1
            ELSE (ig.fecha_vigencia_fin - CURRENT_DATE)
        END as dias_hasta_vencimiento,
        total_records as total_count
    FROM catalogo_giros cg
    LEFT JOIN importes_giros ig ON cg.id_giro = ig.id_giro
    WHERE (p_filtro = '' OR
           LOWER(cg.nombre_giro) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(cg.codigo_giro) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(cg.categoria) LIKE '%' || LOWER(p_filtro) || '%')
    AND (p_categoria = 'TODOS' OR LOWER(cg.categoria) = LOWER(p_categoria))
    AND (p_estado_importe = 'TODOS' OR
         (p_estado_importe = 'ASIGNADO' AND ig.importe_base IS NOT NULL) OR
         (p_estado_importe = 'PENDIENTE' AND ig.importe_base IS NULL))
    AND (p_vigencia = 'TODOS' OR
         (p_vigencia = 'VIGENTE' AND COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) > CURRENT_DATE) OR
         (p_vigencia = 'PROXIMO_VENCER' AND COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'))
    AND COALESCE(cg.activo, 'S') = 'S'
    ORDER BY cg.categoria, cg.nombre_giro
    OFFSET p_offset LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

-- 2. SP para obtener detalle de un giro específico
CREATE OR REPLACE FUNCTION sp_catalogo_giros_importes_detalle(
    p_id_giro INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    codigo_giro VARCHAR(10),
    nombre_giro VARCHAR(200),
    descripcion_completa TEXT,
    categoria VARCHAR(50),
    subcategoria VARCHAR(80),
    importe_base DECIMAL(10,2),
    importe_zona_a DECIMAL(10,2),
    importe_zona_b DECIMAL(10,2),
    importe_zona_c DECIMAL(10,2),
    moneda VARCHAR(5),
    fecha_vigencia_inicio DATE,
    fecha_vigencia_fin DATE,
    factor_indexacion DECIMAL(5,4),
    usuario_creacion VARCHAR(20),
    fecha_creacion TIMESTAMP,
    usuario_modificacion VARCHAR(20),
    fecha_modificacion TIMESTAMP,
    observaciones TEXT,
    historial_cambios TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cg.id_giro,
        cg.codigo_giro,
        cg.nombre_giro,
        COALESCE(cg.descripcion_completa, '') as descripcion_completa,
        COALESCE(cg.categoria, 'SIN_CATEGORIA') as categoria,
        COALESCE(cg.subcategoria, '') as subcategoria,
        COALESCE(ig.importe_base, 0.00) as importe_base,
        COALESCE(ig.importe_zona_a, 0.00) as importe_zona_a,
        COALESCE(ig.importe_zona_b, 0.00) as importe_zona_b,
        COALESCE(ig.importe_zona_c, 0.00) as importe_zona_c,
        COALESCE(ig.moneda, 'MXN') as moneda,
        COALESCE(ig.fecha_vigencia_inicio, CURRENT_DATE) as fecha_vigencia_inicio,
        COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) as fecha_vigencia_fin,
        COALESCE(ig.factor_indexacion, 1.0000) as factor_indexacion,
        COALESCE(ig.usuario_creacion, '') as usuario_creacion,
        COALESCE(ig.fecha_creacion, CURRENT_TIMESTAMP) as fecha_creacion,
        COALESCE(ig.usuario_modificacion, '') as usuario_modificacion,
        COALESCE(ig.fecha_modificacion, CURRENT_TIMESTAMP) as fecha_modificacion,
        COALESCE(ig.observaciones, '') as observaciones,
        COALESCE(ig.historial_cambios, '') as historial_cambios
    FROM catalogo_giros cg
    LEFT JOIN importes_giros ig ON cg.id_giro = ig.id_giro
    WHERE cg.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

-- 3. SP para actualizar importes de un giro
CREATE OR REPLACE FUNCTION sp_catalogo_giros_importes_update(
    p_id_giro INTEGER,
    p_importe_base DECIMAL(10,2),
    p_importe_zona_a DECIMAL(10,2) DEFAULT NULL,
    p_importe_zona_b DECIMAL(10,2) DEFAULT NULL,
    p_importe_zona_c DECIMAL(10,2) DEFAULT NULL,
    p_fecha_vigencia_inicio DATE DEFAULT NULL,
    p_fecha_vigencia_fin DATE DEFAULT NULL,
    p_factor_indexacion DECIMAL(5,4) DEFAULT 1.0000,
    p_usuario_modificacion VARCHAR(20),
    p_observaciones TEXT DEFAULT ''
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_giro_actualizado INTEGER
) AS $$
DECLARE
    giro_exists INTEGER;
    importe_exists INTEGER;
    affected_rows INTEGER;
    historial_anterior TEXT;
    nuevo_historial TEXT;
BEGIN
    -- Verificar si el giro existe
    SELECT COUNT(*) INTO giro_exists
    FROM catalogo_giros
    WHERE id_giro = p_id_giro AND COALESCE(activo, 'S') = 'S';

    IF giro_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'Giro no encontrado o inactivo', p_id_giro;
        RETURN;
    END IF;

    -- Verificar si ya tiene importes asignados
    SELECT COUNT(*) INTO importe_exists
    FROM importes_giros
    WHERE id_giro = p_id_giro;

    -- Obtener historial anterior para auditoría
    SELECT COALESCE(historial_cambios, '') INTO historial_anterior
    FROM importes_giros
    WHERE id_giro = p_id_giro;

    -- Crear nuevo registro de historial
    nuevo_historial := historial_anterior ||
        CASE WHEN historial_anterior != '' THEN E'\n' ELSE '' END ||
        TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' - ' ||
        p_usuario_modificacion || ': Importe base: $' || p_importe_base::TEXT;

    IF importe_exists = 0 THEN
        -- Insertar nuevo registro de importes
        INSERT INTO importes_giros (
            id_giro,
            importe_base,
            importe_zona_a,
            importe_zona_b,
            importe_zona_c,
            moneda,
            fecha_vigencia_inicio,
            fecha_vigencia_fin,
            factor_indexacion,
            usuario_creacion,
            fecha_creacion,
            usuario_modificacion,
            fecha_modificacion,
            observaciones,
            historial_cambios
        ) VALUES (
            p_id_giro,
            p_importe_base,
            COALESCE(p_importe_zona_a, p_importe_base * 0.8),
            COALESCE(p_importe_zona_b, p_importe_base * 0.6),
            COALESCE(p_importe_zona_c, p_importe_base * 0.4),
            'MXN',
            COALESCE(p_fecha_vigencia_inicio, CURRENT_DATE),
            p_fecha_vigencia_fin,
            p_factor_indexacion,
            p_usuario_modificacion,
            CURRENT_TIMESTAMP,
            p_usuario_modificacion,
            CURRENT_TIMESTAMP,
            p_observaciones,
            nuevo_historial
        );

        RETURN QUERY SELECT TRUE, 'Importes asignados correctamente', p_id_giro;
    ELSE
        -- Actualizar importes existentes
        UPDATE importes_giros SET
            importe_base = p_importe_base,
            importe_zona_a = COALESCE(p_importe_zona_a, p_importe_base * 0.8),
            importe_zona_b = COALESCE(p_importe_zona_b, p_importe_base * 0.6),
            importe_zona_c = COALESCE(p_importe_zona_c, p_importe_base * 0.4),
            fecha_vigencia_inicio = COALESCE(p_fecha_vigencia_inicio, fecha_vigencia_inicio),
            fecha_vigencia_fin = p_fecha_vigencia_fin,
            factor_indexacion = p_factor_indexacion,
            usuario_modificacion = p_usuario_modificacion,
            fecha_modificacion = CURRENT_TIMESTAMP,
            observaciones = p_observaciones,
            historial_cambios = nuevo_historial
        WHERE id_giro = p_id_giro;

        GET DIAGNOSTICS affected_rows = ROW_COUNT;

        IF affected_rows > 0 THEN
            RETURN QUERY SELECT TRUE, 'Importes actualizados correctamente', p_id_giro;
        ELSE
            RETURN QUERY SELECT FALSE, 'Error al actualizar los importes', p_id_giro;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 4. SP para obtener estadísticas del catálogo
CREATE OR REPLACE FUNCTION sp_catalogo_giros_importes_estadisticas()
RETURNS TABLE (
    total_giros INTEGER,
    giros_con_importe INTEGER,
    giros_pendientes INTEGER,
    giros_vigentes INTEGER,
    giros_proximos_vencer INTEGER,
    giros_vencidos INTEGER,
    ingresos_estimados_mensual DECIMAL(15,2),
    promedio_importe_por_categoria JSON
) AS $$
DECLARE
    estadisticas_categoria JSON;
BEGIN
    -- Calcular estadísticas por categoría
    SELECT json_object_agg(categoria, promedio_importe) INTO estadisticas_categoria
    FROM (
        SELECT
            COALESCE(cg.categoria, 'SIN_CATEGORIA') as categoria,
            ROUND(AVG(COALESCE(ig.importe_base, 0)), 2) as promedio_importe
        FROM catalogo_giros cg
        LEFT JOIN importes_giros ig ON cg.id_giro = ig.id_giro
        WHERE COALESCE(cg.activo, 'S') = 'S'
        GROUP BY cg.categoria
    ) stats_cat;

    RETURN QUERY
    SELECT
        COUNT(cg.id_giro)::INTEGER as total_giros,
        COUNT(CASE WHEN ig.importe_base IS NOT NULL THEN 1 END)::INTEGER as giros_con_importe,
        COUNT(CASE WHEN ig.importe_base IS NULL THEN 1 END)::INTEGER as giros_pendientes,
        COUNT(CASE WHEN ig.importe_base IS NOT NULL AND COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) > CURRENT_DATE THEN 1 END)::INTEGER as giros_vigentes,
        COUNT(CASE WHEN ig.importe_base IS NOT NULL AND COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days' THEN 1 END)::INTEGER as giros_proximos_vencer,
        COUNT(CASE WHEN ig.importe_base IS NOT NULL AND COALESCE(ig.fecha_vigencia_fin, '9999-12-31'::DATE) <= CURRENT_DATE THEN 1 END)::INTEGER as giros_vencidos,
        COALESCE(SUM(ig.importe_base), 0.00) as ingresos_estimados_mensual,
        COALESCE(estadisticas_categoria, '{}'::JSON) as promedio_importe_por_categoria
    FROM catalogo_giros cg
    LEFT JOIN importes_giros ig ON cg.id_giro = ig.id_giro
    WHERE COALESCE(cg.activo, 'S') = 'S';
END;
$$ LANGUAGE plpgsql;

-- 5. SP para asignación masiva de importes
CREATE OR REPLACE FUNCTION sp_catalogo_giros_importes_masivo(
    p_categoria VARCHAR(50),
    p_factor_incremento DECIMAL(5,4) DEFAULT 1.0000,
    p_importe_base_minimo DECIMAL(10,2) DEFAULT 1000.00,
    p_fecha_vigencia_inicio DATE DEFAULT NULL,
    p_fecha_vigencia_fin DATE DEFAULT NULL,
    p_usuario_modificacion VARCHAR(20),
    p_observaciones TEXT DEFAULT 'Actualización masiva'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    giros_procesados INTEGER,
    giros_actualizados INTEGER,
    giros_error INTEGER
) AS $$
DECLARE
    total_giros INTEGER;
    giros_actualizados_count INTEGER := 0;
    giros_error_count INTEGER := 0;
    giro_record RECORD;
    nuevo_importe DECIMAL(10,2);
BEGIN
    -- Contar giros a procesar
    SELECT COUNT(*) INTO total_giros
    FROM catalogo_giros
    WHERE (p_categoria = 'TODOS' OR LOWER(categoria) = LOWER(p_categoria))
    AND COALESCE(activo, 'S') = 'S';

    -- Procesar cada giro
    FOR giro_record IN
        SELECT cg.id_giro, cg.codigo_giro, cg.nombre_giro,
               COALESCE(ig.importe_base, p_importe_base_minimo) as importe_actual
        FROM catalogo_giros cg
        LEFT JOIN importes_giros ig ON cg.id_giro = ig.id_giro
        WHERE (p_categoria = 'TODOS' OR LOWER(cg.categoria) = LOWER(p_categoria))
        AND COALESCE(cg.activo, 'S') = 'S'
    LOOP
        BEGIN
            -- Calcular nuevo importe
            nuevo_importe := giro_record.importe_actual * p_factor_incremento;

            -- Actualizar o insertar importe
            PERFORM sp_catalogo_giros_importes_update(
                giro_record.id_giro,
                nuevo_importe,
                NULL, NULL, NULL,
                COALESCE(p_fecha_vigencia_inicio, CURRENT_DATE),
                p_fecha_vigencia_fin,
                p_factor_incremento,
                p_usuario_modificacion,
                p_observaciones || ' - Factor: ' || p_factor_incremento::TEXT
            );

            giros_actualizados_count := giros_actualizados_count + 1;

        EXCEPTION WHEN OTHERS THEN
            giros_error_count := giros_error_count + 1;
        END;
    END LOOP;

    RETURN QUERY
    SELECT
        (giros_error_count = 0) as success,
        CASE
            WHEN giros_error_count = 0 THEN 'Actualización masiva completada exitosamente'
            ELSE 'Actualización completada con ' || giros_error_count || ' errores'
        END as message,
        total_giros as giros_procesados,
        giros_actualizados_count as giros_actualizados,
        giros_error_count as giros_error;
END;
$$ LANGUAGE plpgsql;

-- 6. SP para obtener historial de cambios de importes
CREATE OR REPLACE FUNCTION sp_catalogo_giros_historial_importes(
    p_id_giro INTEGER DEFAULT NULL,
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id_giro INTEGER,
    codigo_giro VARCHAR(10),
    nombre_giro VARCHAR(200),
    importe_anterior DECIMAL(10,2),
    importe_nuevo DECIMAL(10,2),
    porcentaje_cambio DECIMAL(5,2),
    fecha_cambio TIMESTAMP,
    usuario_modificacion VARCHAR(20),
    observaciones TEXT,
    tipo_cambio VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        hig.id_giro,
        cg.codigo_giro,
        cg.nombre_giro,
        hig.importe_anterior,
        hig.importe_nuevo,
        CASE
            WHEN hig.importe_anterior > 0 THEN
                ROUND(((hig.importe_nuevo - hig.importe_anterior) / hig.importe_anterior * 100), 2)
            ELSE 0.00
        END as porcentaje_cambio,
        hig.fecha_cambio,
        hig.usuario_modificacion,
        COALESCE(hig.observaciones, '') as observaciones,
        CASE
            WHEN hig.importe_anterior = 0 THEN 'ASIGNACION'
            WHEN hig.importe_nuevo > hig.importe_anterior THEN 'INCREMENTO'
            WHEN hig.importe_nuevo < hig.importe_anterior THEN 'REDUCCION'
            ELSE 'MANTENIMIENTO'
        END as tipo_cambio
    FROM historial_importes_giros hig
    INNER JOIN catalogo_giros cg ON cg.id_giro = hig.id_giro
    WHERE (p_id_giro IS NULL OR hig.id_giro = p_id_giro)
    ORDER BY hig.fecha_cambio DESC
    OFFSET p_offset LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS DE IMPLEMENTACIÓN:
--
-- 1. Los SPs están diseñados para INFORMIX/PostgreSQL
-- 2. Gestión completa de importes por zonas (A, B, C)
-- 3. Sistema de vigencias y vencimientos
-- 4. Auditoría completa de cambios de importes
-- 5. Asignación masiva con factores de incremento
-- 6. Estadísticas en tiempo real por categoría
-- 7. Historial detallado de modificaciones
-- 8. Cálculo automático de importes por zona
-- =====================================================