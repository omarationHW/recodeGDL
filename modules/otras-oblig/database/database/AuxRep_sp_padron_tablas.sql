-- Stored Procedure: sp_padron_tablas
-- Tipo: Catalog
-- Descripción: Obtiene la información de la tabla de padrones (nombre, descripción) según el parámetro par_tab.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-27 23:08:15

CREATE OR REPLACE FUNCTION sp_padron_tablas(par_tab integer)
RETURNS TABLE(cve_tab integer, nombre text, descripcion text) AS $$
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