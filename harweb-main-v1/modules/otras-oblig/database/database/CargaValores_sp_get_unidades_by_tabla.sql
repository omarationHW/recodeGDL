-- Stored Procedure: sp_get_unidades_by_tabla
-- Tipo: Catalog
-- Descripción: Obtiene las unidades de una tabla para el año actual.
-- Generado para formulario: CargaValores
-- Fecha: 2025-08-27 23:13:46

CREATE OR REPLACE FUNCTION sp_get_unidades_by_tabla(p_cve_tab varchar)
RETURNS TABLE(ejercicio integer, cve_unidad varchar, cve_operatividad varchar, descripcion varchar, costo numeric) AS $$
BEGIN
  RETURN QUERY SELECT ejercicio, cve_unidad, cve_operatividad, descripcion, costo FROM t34_unidades WHERE cve_tab = p_cve_tab AND ejercicio = EXTRACT(YEAR FROM CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;