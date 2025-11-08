-- Stored Procedure: sp_buscar_calles
-- Tipo: Catalog
-- Descripción: Busca calles cuyo nombre contenga el filtro, excluyendo las ocultas (vigente = 'V' y num_tag = 8000).
-- Generado para formulario: formabuscalle
-- Fecha: 2025-08-27 17:47:22

CREATE OR REPLACE FUNCTION sp_buscar_calles(filtro TEXT)
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE calle ILIKE '%' || filtro || '%'
      AND cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      );
END;
$$ LANGUAGE plpgsql;