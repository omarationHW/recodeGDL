-- Stored Procedure: sp_cruces_localiza_calle
-- Tipo: CRUD
-- Descripción: Localiza los datos completos de dos calles por sus claves (puede ser una o ambas). Devuelve tipo=1 para calle1 y tipo=2 para calle2.
-- Generado para formulario: Cruces
-- Fecha: 2025-08-27 17:30:37

CREATE OR REPLACE FUNCTION sp_cruces_localiza_calle(cvecalle1 INTEGER, cvecalle2 INTEGER)
RETURNS TABLE (
    tipo INTEGER,
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    IF cvecalle1 > 0 THEN
        RETURN QUERY
        SELECT 1 AS tipo, cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
        FROM c_calles WHERE cvecalle = cvecalle1;
    END IF;
    IF cvecalle2 > 0 THEN
        RETURN QUERY
        SELECT 2 AS tipo, cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
        FROM c_calles WHERE cvecalle = cvecalle2;
    END IF;
END;
$$ LANGUAGE plpgsql;