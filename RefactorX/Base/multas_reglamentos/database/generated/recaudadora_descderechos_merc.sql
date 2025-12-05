-- ================================================================
-- SP: recaudadora_descderechos_merc
-- Módulo: multas_reglamentos
-- Descripción: Consulta descuentos de derechos de mercado
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-29
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_descderechos_merc(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    clave_cuenta TEXT,
    id_local INTEGER,
    num_mercado SMALLINT,
    local INTEGER,
    nombre VARCHAR,
    descuento SMALLINT,
    desde TEXT,
    hasta TEXT,
    estatus TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar descuentos de mercados
    RETURN QUERY
    SELECT
        CAST(l.id_local AS TEXT) AS clave_cuenta,
        l.id_local,
        l.num_mercado,
        l.local,
        l.nombre,
        d.porcentaje AS descuento,
        CAST(TRIM(d.axoini) AS TEXT) AS desde,
        CAST(TRIM(d.axofin) AS TEXT) AS hasta,
        CASE
            WHEN d.estado = 'V' THEN CAST('Vigente' AS TEXT)
            WHEN d.estado = 'C' THEN CAST('Cancelado' AS TEXT)
            ELSE CAST('Inactivo' AS TEXT)
        END AS estatus
    FROM comun.ta_11_locales l
    JOIN comun.descrecmerc d ON l.id_local = d.id_local
    WHERE
        (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR CAST(l.id_local AS VARCHAR) = p_clave_cuenta)
        AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR
             (CAST(TRIM(d.axoini) AS INTEGER) <= p_ejercicio AND CAST(TRIM(d.axofin) AS INTEGER) >= p_ejercicio))
    ORDER BY l.id_local, d.axoini;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_descderechos_merc(VARCHAR, INTEGER) IS 'Consulta descuentos de derechos de mercado desde ta_11_locales y descrecmerc.';
