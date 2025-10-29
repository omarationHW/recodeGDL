-- Stored Procedure: sp_get_avaluos
-- Tipo: Report
-- Descripción: Obtiene los avaluos asociados a una clave catastral y subpredio.
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-26 15:06:43

CREATE OR REPLACE FUNCTION sp_get_avaluos(p_cvecatnva TEXT, p_subpredio INTEGER)
RETURNS TABLE(
    cveavaluo INTEGER,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC,
    indiviso NUMERIC,
    feccap DATE,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.cveavaluo, a.supterr, a.supconst, a.valorterr, a.valorconst, a.valfiscal, a.indiviso, a.feccap, a.observacion
    FROM avaluos a
    JOIN convcta v ON v.cvecuenta = a.cvecuenta
    WHERE v.cvecatnva = p_cvecatnva
      AND (a.subpredio = p_subpredio OR p_subpredio IS NULL)
      AND a.vigencia = 'V';
END;
$$ LANGUAGE plpgsql;