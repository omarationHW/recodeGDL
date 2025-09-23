-- Stored Procedure: get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene información de la tabla y su descripción
-- Generado para formulario: GAdeudosGral
-- Fecha: 2025-08-27 13:49:09

CREATE OR REPLACE FUNCTION get_tablas(par_tab TEXT)
RETURNS TABLE(
  cve_tab TEXT,
  nombre TEXT,
  descripcion TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cve_tab, a.nombre, b.descripcion
  FROM t34_tablas a
  JOIN t34_unidades b ON b.cve_tab = a.cve_tab
  WHERE a.cve_tab = par_tab
  GROUP BY a.cve_tab, a.nombre, b.descripcion
  ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;