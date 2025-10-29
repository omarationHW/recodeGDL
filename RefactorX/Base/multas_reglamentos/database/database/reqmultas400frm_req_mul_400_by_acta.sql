-- Stored Procedure: req_mul_400_by_acta
-- Tipo: Report
-- Descripción: Consulta requerimientos de multas 400 por dependencia, año de acta, número de acta y tipo.
-- Generado para formulario: reqmultas400frm
-- Fecha: 2025-08-27 14:47:13

CREATE OR REPLACE FUNCTION req_mul_400_by_acta(
    dep VARCHAR,
    axo INTEGER,
    numacta INTEGER,
    tipo INTEGER
)
RETURNS SETOF req_mul_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM req_mul_400
    WHERE SUBSTRING(cvelet FROM 4 FOR 3) = dep
      AND cvenum = axo
      AND ctarfc = numacta
      AND cveapl = tipo;
END;
$$ LANGUAGE plpgsql;