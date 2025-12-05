-- ================================================================
-- SP: recaudadora_pagos_espe
-- Módulo: multas_reglamentos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-04
-- Descripción: Lista los pagos especiales autorizados filtrados por cuenta y año
-- ================================================================

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_pagos_espe(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cveaut INTEGER,
    cvecuenta INTEGER,
    bimestre_inicio SMALLINT,
    año_inicio SMALLINT,
    bimestre_fin SMALLINT,
    año_fin SMALLINT,
    fecha_autorizacion DATE,
    autorizado_por VARCHAR,
    cve_pago INTEGER,
    estado VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cuenta INTEGER;
BEGIN
    -- Convertir cuenta a integer si es proporcionada y no está vacía
    IF p_clave_cuenta IS NOT NULL AND TRIM(p_clave_cuenta) <> '' THEN
        BEGIN
            v_cuenta := p_clave_cuenta::INTEGER;
        EXCEPTION WHEN OTHERS THEN
            v_cuenta := NULL;
        END;
    ELSE
        v_cuenta := NULL;
    END IF;

    -- Si no hay cuenta y no hay ejercicio, no retornar nada (evitar consulta completa)
    IF v_cuenta IS NULL AND (p_ejercicio IS NULL OR p_ejercicio = 0) THEN
        RETURN;
    END IF;

    -- Retornar registros filtrados
    RETURN QUERY
    SELECT
        a.cveaut,
        a.cvecuenta,
        a.bimini AS bimestre_inicio,
        a.axoini AS año_inicio,
        a.bimfin AS bimestre_fin,
        a.axofin AS año_fin,
        a.fecaut AS fecha_autorizacion,
        TRIM(a.autorizo)::VARCHAR AS autorizado_por,
        a.cvepago AS cve_pago,
        CASE
            WHEN a.cvepago IS NULL THEN 'PENDIENTE'
            WHEN a.cvepago = 999999 THEN 'CANCELADO'
            ELSE 'PAGADO'
        END::VARCHAR AS estado
    FROM catastro_gdl.autpagoesp a
    WHERE
        (v_cuenta IS NULL OR a.cvecuenta = v_cuenta)
        AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR a.axoini = p_ejercicio OR a.axofin = p_ejercicio)
    ORDER BY a.fecaut DESC, a.cveaut DESC
    LIMIT 1000; -- Límite de seguridad

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_pagos_espe(VARCHAR, INTEGER) IS
'Lista los pagos especiales autorizados filtrados por cuenta y año. Parámetros: p_clave_cuenta (opcional), p_ejercicio (opcional)';
