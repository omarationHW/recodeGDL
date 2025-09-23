-- Stored Procedure: sp_listar_requerimientos_ejecutor
-- Tipo: Report
-- Descripción: Lista los requerimientos asignados a un ejecutor en una fecha y recaudadora.
-- Generado para formulario: entregafrm
-- Fecha: 2025-08-27 11:57:32

CREATE OR REPLACE FUNCTION sp_listar_requerimientos_ejecutor(
    p_cveejecutor INTEGER,
    p_recaud INTEGER,
    p_fecha DATE
) RETURNS TABLE (
    folioreq INTEGER,
    cvecuenta INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC,
    total NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT folioreq, cvecuenta, impuesto, recargos, gastos, multas, total
    FROM reqpredial
    WHERE cveejecut = p_cveejecutor AND recaud = p_recaud AND fecejec = p_fecha;
END;
$$;