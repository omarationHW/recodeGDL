-- Stored Procedure: sp_buscar_pago
-- Tipo: Report
-- Descripción: Busca un pago por fecha, recaudadora, caja y folio.
-- Generado para formulario: ligapagoTra
-- Fecha: 2025-08-27 12:45:03

CREATE OR REPLACE FUNCTION sp_buscar_pago(
    p_fecha DATE,
    p_recaud INTEGER,
    p_caja VARCHAR,
    p_folio INTEGER
) RETURNS SETOF pagos AS $$
BEGIN
    RETURN QUERY SELECT * FROM pagos WHERE fecha = p_fecha AND recaud = p_recaud AND caja = p_caja AND folio = p_folio AND cveconcepto = 4;
END;
$$ LANGUAGE plpgsql;