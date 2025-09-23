-- Stored Procedure: sp_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene las tablas de facturación y sus descripciones.
-- Generado para formulario: GFacturacion
-- Fecha: 2025-08-28 13:15:04

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab VARCHAR)
RETURNS TABLE(
    cve_tab VARCHAR,
    nombre VARCHAR,
    descripcion VARCHAR
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