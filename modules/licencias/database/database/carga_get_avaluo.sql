-- Stored Procedure: get_avaluo
-- Tipo: Report
-- Descripción: Devuelve los datos de avalúo para una clave catastral.
-- Generado para formulario: carga
-- Fecha: 2025-08-27 16:36:45

CREATE OR REPLACE FUNCTION get_avaluo(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cveavaluo INTEGER,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC,
    perimetro NUMERIC,
    frente NUMERIC,
    profund NUMERIC,
    factor NUMERIC,
    valorunit NUMERIC,
    indiviso NUMERIC,
    frentedis NUMERIC,
    factorajus NUMERIC,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveavaluo, supterr, supconst, valorterr, valorconst, valfiscal, perimetro, frente, profund, factor, valorunit, indiviso, frentedis, factorajus, feccap
    FROM avaluos
    WHERE cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;