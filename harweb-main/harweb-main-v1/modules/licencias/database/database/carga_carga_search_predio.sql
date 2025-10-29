-- Stored Procedure: carga_search_predio
-- Tipo: Catalog
-- Descripción: Búsqueda de predios por criterio flexible (clave, propietario, etc).
-- Generado para formulario: carga
-- Fecha: 2025-08-26 15:04:18

CREATE OR REPLACE FUNCTION carga_search_predio(p_criterio TEXT)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    propietario VARCHAR,
    ubicacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.cvecatnva, c.subpredio, p.propietario, u.ubicacion
    FROM convcta c
    LEFT JOIN propietario p ON p.cvecuenta = c.cvecuenta
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    WHERE c.cvecatnva ILIKE '%'||p_criterio||'%' OR p.propietario ILIKE '%'||p_criterio||'%';
END;
$$ LANGUAGE plpgsql;