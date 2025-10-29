-- Stored Procedure: get_construcciones
-- Tipo: Report
-- Descripción: Devuelve las construcciones asociadas a una clave catastral.
-- Generado para formulario: carga
-- Fecha: 2025-08-27 16:36:45

CREATE OR REPLACE FUNCTION get_construcciones(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvebloque INTEGER,
    cveavaluo INTEGER,
    cveclasif INTEGER,
    estructura INTEGER,
    areaconst NUMERIC,
    importe NUMERIC,
    factorajus NUMERIC,
    vigente VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvebloque, cveavaluo, cveclasif, estructura, areaconst, importe, factorajus, vigente, descripcion
    FROM construc
    WHERE cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;