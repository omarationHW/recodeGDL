-- Stored Procedure: sp_get_deptos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de departamentos con usuarios con privilegios.
-- Generado para formulario: privilegios
-- Fecha: 2025-08-27 18:54:11

CREATE OR REPLACE FUNCTION sp_get_deptos()
RETURNS TABLE (
    cvedepto INTEGER,
    nombredepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvedepto, d.nombredepto
    FROM c_programas p
    INNER JOIN autoriza a ON a.num_tag = p.num_tag
    INNER JOIN usuarios u ON u.usuario = a.usuario
    LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE p.num_tag BETWEEN 8000 AND 8999
    GROUP BY 1,2
    ORDER BY 2;
END;
$$ LANGUAGE plpgsql;