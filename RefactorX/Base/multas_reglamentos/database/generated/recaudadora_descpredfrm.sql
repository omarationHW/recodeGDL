-- ================================================================
-- SP: recaudadora_descpredfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta descuentos prediales
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-30
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_descpredfrm(
    p_cvecat VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvecuenta TEXT,
    cvedescuento TEXT,
    descripcion TEXT,
    porcentaje TEXT,
    ejercicio TEXT,
    bimini TEXT,
    bimfin TEXT,
    fecalta TEXT,
    captalta TEXT,
    status TEXT,
    status_desc TEXT,
    solicitante TEXT,
    observaciones TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar descuentos prediales
    RETURN QUERY
    SELECT
        CAST(d.cvecuenta AS TEXT) AS cvecuenta,
        CAST(d.cvedescuento AS TEXT) AS cvedescuento,
        CAST(TRIM(c.descripcion) AS TEXT) AS descripcion,
        CAST(c.porcentaje AS TEXT) AS porcentaje,
        CAST(c.axodescto AS TEXT) AS ejercicio,
        CAST(d.bimini AS TEXT) AS bimini,
        CAST(d.bimfin AS TEXT) AS bimfin,
        CAST(d.fecalta AS TEXT) AS fecalta,
        CAST(TRIM(d.captalta) AS TEXT) AS captalta,
        CAST(d.status AS TEXT) AS status,
        CAST(
            CASE
                WHEN d.status = 'V' THEN 'Vigente'
                WHEN d.status = 'C' THEN 'Cancelado'
                WHEN d.status = 'M' THEN 'Modificado'
                ELSE 'Desconocido'
            END AS TEXT
        ) AS status_desc,
        CAST(TRIM(d.solicitante) AS TEXT) AS solicitante,
        CAST(COALESCE(d.observaciones, 'Sin observaciones') AS TEXT) AS observaciones
    FROM catastro_gdl.descpred d
    INNER JOIN catastro_gdl.c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE
        (p_cvecat IS NULL OR p_cvecat = '' OR CAST(d.cvecuenta AS VARCHAR) = p_cvecat)
    ORDER BY d.cvecuenta, c.axodescto DESC, d.fecalta DESC;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_descpredfrm(VARCHAR) IS 'Consulta descuentos prediales desde catastro_gdl.descpred y c_descpred.';
