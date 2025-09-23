-- Stored Procedure: sp_get_cfs_historico
-- Tipo: Report
-- Descripción: Obtiene C/F's históricos de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_cfs_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    mpio INTEGER,
    axocomp INTEGER,
    nocomp INTEGER,
    escritura INTEGER,
    notario INTEGER,
    mpio_notario INTEGER,
    estado VARCHAR,
    fideicomisario VARCHAR,
    fideicomitente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT mpio, axocomp, nocomp, escritura, notario, mpio_notario, estado, fideicomisario, fideicomitente
    FROM cfs_400
    WHERE cvecuenta = p_cvecuenta
    ORDER BY axocomp DESC;
END;
$$ LANGUAGE plpgsql;