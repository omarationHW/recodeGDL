-- Stored Procedure: get_t34_tablas
-- Tipo: Catalog
-- Descripción: Obtiene todas las tablas activas para carga de cartera.
-- Generado para formulario: CargaCartera
-- Fecha: 2025-08-27 23:10:55

CREATE OR REPLACE FUNCTION get_t34_tablas()
RETURNS TABLE(id_34_tab INTEGER, cve_tab VARCHAR, nombre VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_34_tab, cve_tab, nombre FROM t34_tablas WHERE auto_tab > 0 ORDER BY auto_tab;
END;
$$ LANGUAGE plpgsql;