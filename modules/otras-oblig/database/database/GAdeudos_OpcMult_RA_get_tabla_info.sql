-- Stored Procedure: get_tabla_info
-- Tipo: Catalog
-- Descripción: Obtiene información de la tabla y su descripción.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-27 23:39:10

CREATE OR REPLACE FUNCTION get_tabla_info(par_tab integer)
RETURNS TABLE (
    cve_tab text,
    nombre text,
    descripcion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab::text
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;