-- ================================================================
-- SP: recaudadora_dderechoslic
-- Módulo: multas_reglamentos
-- Descripción: Consulta derechos de licencias con detalle por año
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-28
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_dderechoslic(
    p_licencia INTEGER DEFAULT NULL
)
RETURNS TABLE (
    licencia INTEGER,
    id_licencia INTEGER,
    propietario CHARACTER(80),
    actividad CHARACTER(130),
    domicilio CHARACTER(50),
    axo SMALLINT,
    derechos NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    total_licencia NUMERIC,
    pagado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar derechos de licencias con detalle por año
    RETURN QUERY
    SELECT
        l.licencia,
        l.id_licencia,
        l.propietario,
        l.actividad,
        l.domicilio,
        d.axo,
        d.derechos,
        d.recargos,
        COALESCE(s.multas, 0) AS multas,
        s.total AS total_licencia,
        CASE WHEN d.cvepago > 0 THEN 'Sí' ELSE 'No' END AS pagado
    FROM catastro_gdl.licencias l
    JOIN catastro_gdl.saldos_lic s ON l.id_licencia = s.id_licencia
    LEFT JOIN catastro_gdl.detsal_lic d ON l.id_licencia = d.id_licencia
    WHERE
        (p_licencia IS NULL OR l.licencia = p_licencia)
        AND l.licencia > 0
        AND s.derechos > 0
        AND (d.derechos IS NULL OR d.derechos > 0)
    ORDER BY l.licencia, d.axo DESC;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_dderechoslic(INTEGER) IS 'Consulta derechos de licencias con detalle por año desde tabla licencias, saldos_lic y detsal_lic.';
