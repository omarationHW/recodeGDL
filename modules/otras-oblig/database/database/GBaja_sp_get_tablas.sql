-- Stored Procedure: sp_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene la información de la tabla de concesiones.
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 13:58:32

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab TEXT)
RETURNS TABLE (
    cve_tab TEXT,
    nombre TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT cve_tab, nombre, descripcion FROM t34_tablas WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;