-- Stored Procedure: sp_cruces_search_calle1
-- Tipo: Catalog
-- Descripción: Busca calles para el primer campo de cruce, excluyendo las escondidas y filtrando por nombre.
-- Generado para formulario: Cruces
-- Fecha: 2025-08-27 17:30:37

CREATE OR REPLACE FUNCTION sp_cruces_search_calle1(search_text TEXT)
RETURNS TABLE (
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
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE UPPER(calle) LIKE '%' || UPPER(search_text) || '%'
      AND cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      );
END;
$$ LANGUAGE plpgsql;