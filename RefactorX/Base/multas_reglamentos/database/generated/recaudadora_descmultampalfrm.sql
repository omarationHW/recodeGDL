-- ================================================================
-- SP: recaudadora_descmultampalfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta descuentos de multas municipales (UNA SOLA TABLA)
-- Autor: Sistema RefactorX
-- Fecha: 2025-01-05
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_descmultampalfrm(
    p_clave_cuenta TEXT DEFAULT NULL
)
RETURNS TABLE (
    id_multa TEXT,
    tipo_descto TEXT,
    valor_descuento TEXT,
    cvepago TEXT,
    fecha_descuento TEXT,
    capturista TEXT,
    observacion TEXT,
    autoriza TEXT,
    estado_desc TEXT,
    folio TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_multa INTEGER;
    v_tiene_filtro BOOLEAN;
BEGIN
    -- Convertir parámetro TEXT a INTEGER si es numérico (OPTIMIZACIÓN)
    -- Esto permite usar el índice en id_multa directamente
    v_tiene_filtro := (p_clave_cuenta IS NOT NULL AND p_clave_cuenta <> '');

    IF v_tiene_filtro THEN
        BEGIN
            v_id_multa := p_clave_cuenta::INTEGER;
        EXCEPTION WHEN OTHERS THEN
            v_id_multa := NULL;
            v_tiene_filtro := FALSE;
        END;
    END IF;

    -- Retornar descuentos de multas municipales desde UNA SOLA TABLA
    -- OPTIMIZADO: usa índices idx_descmultampal_id_multa y idx_descmultampal_feccap_idmulta
    RETURN QUERY
    SELECT
        CAST(d.id_multa AS TEXT) AS id_multa,
        CAST(
            CASE
                WHEN d.tipo_descto = 'P' THEN 'Porcentaje'
                WHEN d.tipo_descto = 'I' THEN 'Importe'
                ELSE CAST(d.tipo_descto AS TEXT)
            END AS TEXT
        ) AS tipo_descto,
        CAST(COALESCE(d.valor, 0) AS TEXT) AS valor_descuento,
        CAST(d.cvepago AS TEXT) AS cvepago,
        CAST(TO_CHAR(d.feccap, 'YYYY-MM-DD') AS TEXT) AS fecha_descuento,
        CAST(TRIM(d.capturista) AS TEXT) AS capturista,
        CAST(COALESCE(TRIM(d.observacion), '') AS TEXT) AS observacion,
        CAST(d.autoriza AS TEXT) AS autoriza,
        CAST(
            CASE
                WHEN d.estado = 'V' THEN 'Vigente'
                WHEN d.estado = 'P' THEN 'Pagado'
                WHEN d.estado = 'C' THEN 'Cancelado'
                ELSE 'Desconocido'
            END AS TEXT
        ) AS estado_desc,
        CAST(d.folio AS TEXT) AS folio
    FROM catastro_gdl.descmultampal d
    WHERE
        (NOT v_tiene_filtro OR d.id_multa = v_id_multa)
    ORDER BY d.feccap DESC, d.id_multa
    LIMIT CASE WHEN v_tiene_filtro THEN NULL ELSE 1000 END;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_descmultampalfrm(TEXT) IS 'Consulta descuentos de multas municipales desde UNA SOLA tabla: catastro_gdl.descmultampal';
