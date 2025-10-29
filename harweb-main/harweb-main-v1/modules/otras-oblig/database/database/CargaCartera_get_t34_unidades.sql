-- Stored Procedure: get_t34_unidades
-- Tipo: Catalog
-- Descripción: Obtiene las unidades de una tabla y ejercicio.
-- Generado para formulario: CargaCartera
-- Fecha: 2025-08-27 23:10:55

CREATE OR REPLACE FUNCTION get_t34_unidades(par_tabla VARCHAR, par_ejer INTEGER)
RETURNS TABLE(ejercicio INTEGER, cve_unidad VARCHAR, cve_operatividad VARCHAR, descripcion VARCHAR, costo NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT ejercicio, cve_unidad, cve_operatividad, descripcion, costo FROM t34_unidades WHERE cve_tab = par_tabla AND ejercicio = par_ejer;
END;
$$ LANGUAGE plpgsql;