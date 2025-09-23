-- Stored Procedure: req_mul_400_by_folio
-- Tipo: Report
-- Descripción: Consulta requerimientos de multas 400 por año de requerimiento, folio y tipo.
-- Generado para formulario: reqmultas400frm
-- Fecha: 2025-08-27 14:47:13

CREATE OR REPLACE FUNCTION req_mul_400_by_folio(
    axo INTEGER,
    folio INTEGER,
    tipo INTEGER
)
RETURNS SETOF req_mul_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM req_mul_400
    WHERE axoreq = axo
      AND folreq = folio
      AND cveapl = tipo;
END;
$$ LANGUAGE plpgsql;