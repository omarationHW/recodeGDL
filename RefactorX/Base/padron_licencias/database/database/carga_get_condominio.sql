-- Stored Procedure: get_condominio
-- Tipo: Catalog
-- Descripción: Devuelve los datos del condominio asociado a una clave catastral.
-- Generado para formulario: carga
-- Fecha: 2025-08-27 16:36:45

CREATE OR REPLACE FUNCTION get_condominio(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvecond INTEGER,
    nombre VARCHAR,
    tipocond VARCHAR,
    numpred INTEGER,
    escritura INTEGER,
    idnotaria INTEGER,
    fecescrit DATE,
    cvecatnva VARCHAR,
    areacomun NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecond, nombre, tipocond, numpred, escritura, idnotaria, fecescrit, cvecatnva, areacomun
    FROM condominio
    WHERE cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;