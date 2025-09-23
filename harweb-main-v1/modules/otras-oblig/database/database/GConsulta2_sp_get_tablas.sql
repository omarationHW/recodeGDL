-- Stored Procedure: sp_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene la lista de tablas y descripciones
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab VARCHAR)
RETURNS TABLE (
  cve_tab VARCHAR,
  nombre VARCHAR,
  descripcion VARCHAR
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