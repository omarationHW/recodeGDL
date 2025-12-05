-- ================================================================
-- SP: recaudadora_drecgo_trans
-- Módulo: multas_reglamentos
-- Descripción: Consulta derechos de tránsito/transmisión
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-01
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_drecgo_trans(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cve_contribuyente TEXT,
    nombre_completo TEXT,
    tipo_persona TEXT,
    rfc TEXT,
    direccion TEXT,
    colonia TEXT,
    telefono TEXT,
    fecha_captura TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Buscar contribuyentes relacionados con derechos de tránsito/transmisión
    -- Si se proporciona clave_cuenta, buscar ese contribuyente específico
    -- Si no se proporciona, mostrar todos (limitado a 100 registros)

    RETURN QUERY
    SELECT
        CAST(c.cvecont AS TEXT) AS cve_contribuyente,
        CAST(TRIM(c.nombre_completo) AS TEXT) AS nombre_completo,
        CAST(
            CASE
                WHEN c.tipo = 'F' THEN 'Física'
                WHEN c.tipo = 'M' THEN 'Moral'
                ELSE c.tipo
            END AS TEXT
        ) AS tipo_persona,
        CAST(TRIM(c.rfc) AS TEXT) AS rfc,
        CAST(
            TRIM(c.calle) || ' ' ||
            COALESCE(TRIM(c.noexterior), '') ||
            CASE WHEN c.interior IS NOT NULL AND TRIM(c.interior) != ''
                 THEN ' INT ' || TRIM(c.interior)
                 ELSE ''
            END AS TEXT
        ) AS direccion,
        CAST(TRIM(c.colonia) AS TEXT) AS colonia,
        CAST(TRIM(c.telefono) AS TEXT) AS telefono,
        CAST(TO_CHAR(c.feccap, 'DD/MM/YYYY') AS TEXT) AS fecha_captura
    FROM comun.contrib c
    WHERE
        (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR CAST(c.cvecont AS TEXT) = p_clave_cuenta)
        AND c.cvecont IS NOT NULL
    ORDER BY c.cvecont DESC
    LIMIT 100;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_drecgo_trans(VARCHAR) IS 'Consulta derechos de tránsito/transmisión desde comun.contrib';
