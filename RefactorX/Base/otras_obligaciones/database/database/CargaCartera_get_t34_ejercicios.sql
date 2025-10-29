-- Stored Procedure: get_t34_ejercicios
-- Tipo: Catalog
-- Descripción: Obtiene los ejercicios disponibles para una tabla.
-- Generado para formulario: CargaCartera
-- Fecha: 2025-08-27 23:10:55

CREATE OR REPLACE FUNCTION get_t34_ejercicios(par_tabla VARCHAR)
RETURNS TABLE(ejercicio INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT ejercicio FROM t34_unidades WHERE cve_tab = par_tabla GROUP BY ejercicio ORDER BY ejercicio;
END;
$$ LANGUAGE plpgsql;