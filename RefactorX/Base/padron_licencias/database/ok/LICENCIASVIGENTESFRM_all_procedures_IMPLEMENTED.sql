-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun, public;

-- ============================================
-- STORED PROCEDURE PARA LICENCIAS VIGENTES
-- Componente: LicenciasVigentesfrm
-- Convención: sp_licencias_vigentes_stats
-- Implementado: 2025-11-20
-- Tablas: comun.licencias, public.c_giros
-- Módulo: LICENCIASVIGENTESFRM - Estadísticas de licencias vigentes
-- ============================================

-- ============================================
-- SP: sp_licencias_vigentes_stats
-- Tipo: Estadísticas/Consulta
-- Descripción: Obtiene estadísticas completas de licencias vigentes
-- Esquema destino: comun
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_licencias_vigentes_stats()
RETURNS TABLE(
    total_licencias BIGINT,
    licencias_vigentes BIGINT,
    licencias_suspendidas BIGINT,
    licencias_canceladas BIGINT,
    licencias_baja BIGINT,
    promedio_dias_activas NUMERIC(10,2),
    total_por_tipo JSONB,
    total_por_giro JSONB,
    total_por_zona JSONB,
    total_por_estado JSONB,
    resumen_general JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        -- Totales generales
        COUNT(*)::BIGINT as total_licencias,
        COUNT(*) FILTER (WHERE vigente = 'V')::BIGINT as licencias_vigentes,
        COUNT(*) FILTER (WHERE vigente = 'S')::BIGINT as licencias_suspendidas,
        COUNT(*) FILTER (WHERE vigente = 'C')::BIGINT as licencias_canceladas,
        COUNT(*) FILTER (WHERE vigente = 'B')::BIGINT as licencias_baja,

        -- Promedio de días activas (desde fecha_expedicion hasta hoy o hasta fecha_baja)
        AVG(
            CASE
                WHEN fecha_baja IS NOT NULL THEN
                    EXTRACT(DAY FROM (fecha_baja - COALESCE(fecha_expedicion, fecha_registro::DATE)))
                ELSE
                    EXTRACT(DAY FROM (CURRENT_DATE - COALESCE(fecha_expedicion, fecha_registro::DATE)))
            END
        )::NUMERIC(10,2) as promedio_dias_activas,

        -- Distribución por tipo de licencia
        (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'tipo', COALESCE(tipo_licencia, 'SIN TIPO'),
                    'cantidad', cantidad,
                    'porcentaje', ROUND((cantidad::NUMERIC / NULLIF(total::NUMERIC, 0) * 100), 2)
                )
            ), '[]'::jsonb)
            FROM (
                SELECT
                    tipo_licencia,
                    COUNT(*)::BIGINT as cantidad,
                    (SELECT COUNT(*) FROM comun.licencias) as total
                FROM comun.licencias
                GROUP BY tipo_licencia
                ORDER BY COUNT(*) DESC
            ) tipo_stats
        ) as total_por_tipo,

        -- Distribución por giro (top 10)
        (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'giro', giro_nombre,
                    'id_giro', id_giro,
                    'cantidad', cantidad,
                    'porcentaje', ROUND((cantidad::NUMERIC / NULLIF(total::NUMERIC, 0) * 100), 2)
                )
            ), '[]'::jsonb)
            FROM (
                SELECT
                    l.id_giro,
                    COALESCE(g.descripcion, l.giro, 'SIN GIRO') as giro_nombre,
                    COUNT(*)::BIGINT as cantidad,
                    (SELECT COUNT(*) FROM comun.licencias) as total
                FROM comun.licencias l
                LEFT JOIN public.c_giros g ON g.id_giro = l.id_giro
                WHERE l.id_giro IS NOT NULL OR l.giro IS NOT NULL
                GROUP BY l.id_giro, g.descripcion, l.giro
                ORDER BY COUNT(*) DESC
                LIMIT 10
            ) giro_stats
        ) as total_por_giro,

        -- Distribución por zona
        (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'zona', zona,
                    'cantidad', cantidad,
                    'porcentaje', ROUND((cantidad::NUMERIC / NULLIF(total::NUMERIC, 0) * 100), 2)
                )
            ), '[]'::jsonb)
            FROM (
                SELECT
                    COALESCE(zona, 0) as zona,
                    COUNT(*)::BIGINT as cantidad,
                    (SELECT COUNT(*) FROM comun.licencias WHERE zona IS NOT NULL) as total
                FROM comun.licencias
                WHERE zona IS NOT NULL
                GROUP BY zona
                ORDER BY zona
            ) zona_stats
        ) as total_por_zona,

        -- Distribución por estado (vigente)
        (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'estado', estado_desc,
                    'codigo', estado_codigo,
                    'cantidad', cantidad,
                    'porcentaje', ROUND((cantidad::NUMERIC / NULLIF(total::NUMERIC, 0) * 100), 2)
                )
            ), '[]'::jsonb)
            FROM (
                SELECT
                    vigente as estado_codigo,
                    CASE vigente
                        WHEN 'V' THEN 'VIGENTE'
                        WHEN 'S' THEN 'SUSPENDIDA'
                        WHEN 'C' THEN 'CANCELADA'
                        WHEN 'B' THEN 'BAJA'
                        ELSE 'DESCONOCIDO'
                    END as estado_desc,
                    COUNT(*)::BIGINT as cantidad,
                    (SELECT COUNT(*) FROM comun.licencias) as total
                FROM comun.licencias
                GROUP BY vigente
                ORDER BY
                    CASE vigente
                        WHEN 'V' THEN 1
                        WHEN 'S' THEN 2
                        WHEN 'C' THEN 3
                        WHEN 'B' THEN 4
                        ELSE 5
                    END
            ) estado_stats
        ) as total_por_estado,

        -- Resumen general con información adicional
        (
            SELECT jsonb_build_object(
                'ultima_actualizacion', NOW(),
                'fecha_consulta', CURRENT_DATE,
                'licencias_con_adeudo', (
                    SELECT COUNT(DISTINCT id_licencia)
                    FROM comun.adeudos_licencia
                    WHERE pagado = FALSE
                ),
                'licencias_bloqueadas', (
                    SELECT COUNT(*)
                    FROM comun.licencias
                    WHERE bloqueado > 0
                ),
                'superficie_total_autorizada', (
                    SELECT COALESCE(SUM(superficie_autorizada), 0)
                    FROM comun.licencias
                    WHERE vigente = 'V'
                ),
                'inversion_total', (
                    SELECT COALESCE(SUM(inversion), 0)
                    FROM comun.licencias
                    WHERE vigente = 'V'
                ),
                'total_empleados', (
                    SELECT COALESCE(SUM(num_empleados), 0)
                    FROM comun.licencias
                    WHERE vigente = 'V'
                ),
                'licencias_proximas_vencer_30_dias', (
                    SELECT COUNT(*)
                    FROM comun.licencias
                    WHERE vigente = 'V'
                    AND fecha_vencimiento IS NOT NULL
                    AND fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
                ),
                'licencias_proximas_vencer_7_dias', (
                    SELECT COUNT(*)
                    FROM comun.licencias
                    WHERE vigente = 'V'
                    AND fecha_vencimiento IS NOT NULL
                    AND fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
                ),
                'licencias_vencidas', (
                    SELECT COUNT(*)
                    FROM comun.licencias
                    WHERE vigente = 'V'
                    AND fecha_vencimiento IS NOT NULL
                    AND fecha_vencimiento < CURRENT_DATE
                )
            )
        ) as resumen_general
    FROM comun.licencias;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS Y PERMISOS
-- ============================================

COMMENT ON FUNCTION comun.sp_licencias_vigentes_stats() IS
'Obtiene estadísticas completas de licencias vigentes:
- Total de licencias por estado (V, S, C, B)
- Distribución por tipo de licencia
- Distribución por giro (top 10)
- Distribución por zona
- Promedio de días activas
- Resumen general con métricas adicionales
- Licencias próximas a vencer
- Licencias con adeudo
- Licencias bloqueadas';

-- Otorgar permisos de ejecución
GRANT EXECUTE ON FUNCTION comun.sp_licencias_vigentes_stats() TO PUBLIC;

-- ============================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- ============================================

-- Índice para campo vigente (usado en múltiples filtros)
CREATE INDEX IF NOT EXISTS idx_licencias_vigente
ON comun.licencias(vigente);

-- Índice para fecha_vencimiento (usado en cálculos de vencimiento)
CREATE INDEX IF NOT EXISTS idx_licencias_fecha_vencimiento
ON comun.licencias(fecha_vencimiento)
WHERE vigente = 'V';

-- Índice para zona (usado en agrupaciones)
CREATE INDEX IF NOT EXISTS idx_licencias_zona
ON comun.licencias(zona)
WHERE zona IS NOT NULL;

-- Índice para tipo_licencia (usado en agrupaciones)
CREATE INDEX IF NOT EXISTS idx_licencias_tipo
ON comun.licencias(tipo_licencia)
WHERE tipo_licencia IS NOT NULL;

-- Índice para id_giro (usado en JOIN y agrupaciones)
CREATE INDEX IF NOT EXISTS idx_licencias_id_giro
ON comun.licencias(id_giro)
WHERE id_giro IS NOT NULL;

-- Índice para bloqueado (usado en filtros de bloqueo)
CREATE INDEX IF NOT EXISTS idx_licencias_bloqueado
ON comun.licencias(bloqueado)
WHERE bloqueado > 0;

-- ============================================
-- EJEMPLO DE USO
-- ============================================

/*
-- Obtener estadísticas completas de licencias vigentes
SELECT * FROM comun.sp_licencias_vigentes_stats();

-- Resultado esperado:
-- {
--   "total_licencias": 1250,
--   "licencias_vigentes": 1100,
--   "licencias_suspendidas": 50,
--   "licencias_canceladas": 75,
--   "licencias_baja": 25,
--   "promedio_dias_activas": 1825.50,
--   "total_por_tipo": [
--     {"tipo": "COMERCIAL", "cantidad": 800, "porcentaje": 64.00},
--     {"tipo": "SERVICIOS", "cantidad": 300, "porcentaje": 24.00},
--     {"tipo": "INDUSTRIAL", "cantidad": 150, "porcentaje": 12.00}
--   ],
--   "total_por_giro": [
--     {"giro": "RESTAURANTE", "id_giro": 123, "cantidad": 250, "porcentaje": 20.00},
--     {"giro": "COMERCIO AL POR MENOR", "id_giro": 456, "cantidad": 180, "porcentaje": 14.40},
--     ...
--   ],
--   "total_por_zona": [
--     {"zona": 1, "cantidad": 400, "porcentaje": 32.00},
--     {"zona": 2, "cantidad": 350, "porcentaje": 28.00},
--     ...
--   ],
--   "total_por_estado": [
--     {"estado": "VIGENTE", "codigo": "V", "cantidad": 1100, "porcentaje": 88.00},
--     {"estado": "SUSPENDIDA", "codigo": "S", "cantidad": 50, "porcentaje": 4.00},
--     ...
--   ],
--   "resumen_general": {
--     "ultima_actualizacion": "2025-11-20T14:30:00",
--     "fecha_consulta": "2025-11-20",
--     "licencias_con_adeudo": 45,
--     "licencias_bloqueadas": 12,
--     "superficie_total_autorizada": 125000.50,
--     "inversion_total": 50000000.00,
--     "total_empleados": 8500,
--     "licencias_proximas_vencer_30_dias": 25,
--     "licencias_proximas_vencer_7_dias": 8,
--     "licencias_vencidas": 15
--   }
-- }

-- Acceder a campos específicos del JSON
SELECT
    total_licencias,
    licencias_vigentes,
    total_por_tipo->0->>'tipo' as tipo_mas_comun,
    total_por_tipo->0->>'cantidad' as cantidad_tipo_mas_comun,
    resumen_general->>'total_empleados' as total_empleados
FROM comun.sp_licencias_vigentes_stats();

-- Extraer solo licencias próximas a vencer
SELECT
    resumen_general->>'licencias_proximas_vencer_30_dias' as proximas_30_dias,
    resumen_general->>'licencias_proximas_vencer_7_dias' as proximas_7_dias,
    resumen_general->>'licencias_vencidas' as vencidas
FROM comun.sp_licencias_vigentes_stats();

-- Análisis de distribución por giro (expandir JSONB)
SELECT
    g.value->>'giro' as giro,
    g.value->>'cantidad' as cantidad,
    g.value->>'porcentaje' as porcentaje
FROM comun.sp_licencias_vigentes_stats(),
LATERAL jsonb_array_elements(total_por_giro) as g
ORDER BY (g.value->>'cantidad')::INTEGER DESC;

*/

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
