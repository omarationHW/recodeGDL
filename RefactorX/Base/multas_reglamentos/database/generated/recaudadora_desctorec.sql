-- ================================================================
-- SP: recaudadora_desctorec
-- Módulo: multas_reglamentos
-- Descripción: Consulta descuentos de recargos
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-30
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_desctorec(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvecuenta TEXT,
    axoini TEXT,
    bimini TEXT,
    axofin TEXT,
    bimfin TEXT,
    porcentaje TEXT,
    fecalta TEXT,
    captalta TEXT,
    fecbaja TEXT,
    captbaja TEXT,
    vigencia TEXT,
    vigencia_desc TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar descuentos de recargos
    RETURN QUERY
    SELECT
        CAST(d.cvecuenta AS TEXT) AS cvecuenta,
        CAST(d.axoini AS TEXT) AS axoini,
        CAST(d.bimini AS TEXT) AS bimini,
        CAST(d.axofin AS TEXT) AS axofin,
        CAST(d.bimfin AS TEXT) AS bimfin,
        CAST(d.porcentaje AS TEXT) AS porcentaje,
        CAST(d.fecalta AS TEXT) AS fecalta,
        CAST(TRIM(d.captalta) AS TEXT) AS captalta,
        CAST(d.fecbaja AS TEXT) AS fecbaja,
        CAST(TRIM(COALESCE(d.captbaja, '')) AS TEXT) AS captbaja,
        CAST(d.vigencia AS TEXT) AS vigencia,
        CAST(
            CASE
                WHEN d.vigencia = 'V' THEN 'Vigente'
                WHEN d.vigencia = 'P' THEN 'Pagado'
                WHEN d.vigencia = 'C' THEN 'Cancelado'
                WHEN d.vigencia = 'B' THEN 'Bloqueado'
                ELSE 'Desconocido'
            END AS TEXT
        ) AS vigencia_desc
    FROM catastro_gdl.descrec d
    WHERE
        (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR CAST(d.cvecuenta AS VARCHAR) = p_clave_cuenta)
    ORDER BY d.cvecuenta, d.axoini DESC, d.bimini DESC;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_desctorec(VARCHAR) IS 'Consulta descuentos de recargos desde catastro_gdl.descrec.';
