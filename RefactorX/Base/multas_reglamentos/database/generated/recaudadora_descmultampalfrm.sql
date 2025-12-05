-- ================================================================
-- SP: recaudadora_descmultampalfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta descuentos de multas municipales
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-30
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_descmultampalfrm(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_multa TEXT,
    num_acta TEXT,
    fecha_acta TEXT,
    contribuyente TEXT,
    domicilio TEXT,
    num_licencia TEXT,
    multa TEXT,
    total TEXT,
    tipo_descto TEXT,
    valor_descuento TEXT,
    estado_desc TEXT,
    fecha_descuento TEXT,
    observacion TEXT,
    autoriza TEXT,
    folio TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar descuentos de multas municipales
    RETURN QUERY
    SELECT
        CAST(m.id_multa AS TEXT) AS id_multa,
        CAST(m.num_acta AS TEXT) AS num_acta,
        CAST(m.fecha_acta AS TEXT) AS fecha_acta,
        CAST(TRIM(m.contribuyente) AS TEXT) AS contribuyente,
        CAST(TRIM(m.domicilio) AS TEXT) AS domicilio,
        CAST(m.num_licencia AS TEXT) AS num_licencia,
        CAST(m.multa AS TEXT) AS multa,
        CAST(m.total AS TEXT) AS total,
        CAST(
            CASE
                WHEN d.tipo_descto = 'P' THEN 'Porcentaje'
                WHEN d.tipo_descto = 'I' THEN 'Importe'
                ELSE CAST(d.tipo_descto AS TEXT)
            END AS TEXT
        ) AS tipo_descto,
        CAST(d.valor AS TEXT) AS valor_descuento,
        CAST(
            CASE
                WHEN d.estado = 'V' THEN 'Vigente'
                WHEN d.estado = 'P' THEN 'Pagado'
                WHEN d.estado = 'C' THEN 'Cancelado'
                ELSE 'Desconocido'
            END AS TEXT
        ) AS estado_desc,
        CAST(d.feccap AS TEXT) AS fecha_descuento,
        CAST(COALESCE(d.observacion, 'Sin observación') AS TEXT) AS observacion,
        CAST(d.autoriza AS TEXT) AS autoriza,
        CAST(d.folio AS TEXT) AS folio
    FROM catastro_gdl.multas m
    INNER JOIN catastro_gdl.descmultampal d ON m.id_multa = d.id_multa
    WHERE
        (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR CAST(m.id_multa AS VARCHAR) = p_clave_cuenta)
    ORDER BY m.id_multa, d.feccap DESC;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_descmultampalfrm(VARCHAR) IS 'Consulta descuentos de multas municipales desde catastro_gdl.multas y descmultampal.';
