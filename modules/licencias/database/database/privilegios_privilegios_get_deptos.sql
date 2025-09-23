-- Stored Procedure: privilegios_get_deptos
-- Tipo: Catalog
-- Descripción: Obtiene la lista de departamentos con usuarios autorizados
-- Generado para formulario: privilegios
-- Fecha: 2025-08-26 17:28:26

CREATE OR REPLACE FUNCTION privilegios_get_deptos()
RETURNS TABLE(cvedepto INTEGER, nombredepto TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT d.cvedepto, d.nombredepto
  FROM c_programas p
  INNER JOIN autoriza a ON a.num_tag = p.num_tag
  INNER JOIN usuarios u ON u.usuario = a.usuario
  LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
  WHERE p.num_tag BETWEEN 8000 AND 8999
  GROUP BY d.cvedepto, d.nombredepto
  ORDER BY d.nombredepto;
END;
$$ LANGUAGE plpgsql;