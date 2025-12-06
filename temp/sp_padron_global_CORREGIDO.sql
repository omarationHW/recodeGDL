-- =====================================================
-- Stored Procedure: sp_padron_global CORREGIDO
-- Fecha: 2025-12-03
-- Descripción: Retorna el padrón global de locales
-- =====================================================
-- PROBLEMA ORIGINAL:
-- - La columna descripcion_local retornaba CHARACTER VARYING(60)
-- - pero la tabla real tiene CHARACTER(20)
-- - Causaba error de tipos de datos
--
-- SOLUCIÓN:
-- - Ajustados TODOS los tipos de datos para que coincidan EXACTAMENTE
-- - con la estructura real de las tablas
-- - descripcion_local: CHARACTER(20)
-- - bloque: CHARACTER VARYING(2)
-- - superficie: NUMERIC (sin precisión específica)
-- =====================================================

DROP FUNCTION IF EXISTS publico.sp_padron_global(INTEGER, INTEGER, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION publico.sp_padron_global(
    p_year INTEGER,
    p_month INTEGER,
    p_status VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    local INTEGER,
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(2),
    nombre CHARACTER VARYING(60),
    descripcion_local CHARACTER(20),
    superficie NUMERIC,
    vigencia CHARACTER(1),
    clave_cuota SMALLINT,
    descripcion CHARACTER VARYING(30),
    renta NUMERIC(10,2),
    leyenda VARCHAR(50),
    adeudo INTEGER,
    registro VARCHAR(200)
)
AS $$
DECLARE
    v_periodo INTEGER;
BEGIN
    -- Calcular periodo (año + mes en formato YYYYMM)
    v_periodo := (p_year * 100) + p_month;

    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta según lógica
        CASE
            -- PS con clave_cuota 4
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
            -- PS otros
            WHEN l.seccion = 'PS' THEN
                ROUND(((COALESCE(c.importe_cuota, 0) * l.superficie) * 30), 2)
            -- Mercado 214
            WHEN l.num_mercado = 214 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0) * COALESCE(fd.sabadosacum, 1)), 2)
            -- Default
            ELSE
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
        END::NUMERIC(10,2) AS renta,
        -- Leyenda de adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::VARCHAR(50)
            ELSE 'Local al Corriente de Pagos'::VARCHAR(50)
        END AS leyenda,
        -- Indicador de adeudo (0 o 1)
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END::INTEGER AS adeudo,
        -- Registro concatenado
        (l.oficina::TEXT || ' ' ||
         l.num_mercado::TEXT || ' ' ||
         l.categoria::TEXT || ' ' ||
         l.seccion || ' ' ||
         l.local::TEXT || ' ' ||
         COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::VARCHAR(200) AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND c.seccion = l.seccion
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT
            al.id_local,
            COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local al
        WHERE (al.axo = p_year AND al.periodo <= p_month)
           OR (al.axo < p_year)
        GROUP BY al.id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE
        (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY
        l.vigencia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PRUEBAS
-- =====================================================
-- Ejecutar con parámetros de prueba:
-- SELECT * FROM publico.sp_padron_global(2025, 12, 'A') LIMIT 10;
-- SELECT * FROM publico.sp_padron_global(2025, 12, 'T') LIMIT 10;
--
-- Contar registros:
-- SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'A');
-- SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'T');
-- =====================================================
