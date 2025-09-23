-- Stored Procedure: sp_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene todas las tablas/rubros activos para carga de valores.
-- Generado para formulario: CargaValores
-- Fecha: 2025-08-27 23:13:46

CREATE OR REPLACE FUNCTION sp_get_tablas()
RETURNS TABLE(id_34_tab integer, cve_tab varchar, nombre varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_34_tab, cve_tab, nombre FROM t34_tablas WHERE auto_tab > 0 ORDER BY auto_tab;
END;
$$ LANGUAGE plpgsql;