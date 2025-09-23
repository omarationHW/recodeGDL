-- Stored Procedure: sp_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene el nombre y descripción de la tabla de contratos.
-- Generado para formulario: GConsulta
-- Fecha: 2025-08-27 16:02:36

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab integer)
RETURNS TABLE (
    cve_tab varchar,
    nombre varchar,
    descripcion varchar
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