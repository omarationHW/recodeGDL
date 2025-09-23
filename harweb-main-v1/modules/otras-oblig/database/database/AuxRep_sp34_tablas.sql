-- Stored Procedure: sp34_tablas
-- Tipo: Catalog
-- Descripción: Obtiene información de la tabla y sus unidades.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-28 12:38:35

CREATE OR REPLACE FUNCTION sp34_tablas(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    nombre varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;