-- Stored Procedure: sp_gadeudos_tablas
-- Tipo: Catalog
-- Descripción: Devuelve información de la tabla/rubro
-- Generado para formulario: GAdeudos
-- Fecha: 2025-08-28 12:49:54

CREATE OR REPLACE FUNCTION sp_gadeudos_tablas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    nombre TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    LEFT JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;