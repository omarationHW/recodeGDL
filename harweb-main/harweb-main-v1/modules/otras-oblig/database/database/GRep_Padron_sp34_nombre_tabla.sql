-- Stored Procedure: sp34_nombre_tabla
-- Tipo: Catalog
-- Descripción: Obtiene el nombre de la tabla (rubro) para mostrar en el frontend.
-- Generado para formulario: GRep_Padron
-- Fecha: 2025-08-28 13:21:45

CREATE OR REPLACE FUNCTION sp34_nombre_tabla(par_tab integer)
RETURNS TABLE(nombre text) AS $$
BEGIN
    RETURN QUERY
    SELECT nombre FROM t34_tablas WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;