-- Stored Procedure: sp_menu_get_ejercicios
-- Tipo: Catalog
-- Descripción: Devuelve la lista de ejercicios disponibles.
-- Generado para formulario: Menu
-- Fecha: 2025-08-28 13:23:04

CREATE OR REPLACE FUNCTION sp_menu_get_ejercicios()
RETURNS TABLE(ejercicio INT) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ejercicio_recolec AS ejercicio
    FROM ta_16_unidades
    ORDER BY ejercicio_recolec;
END;
$$ LANGUAGE plpgsql;