-- Stored Procedure: sp_get_calle
-- Tipo: Catalog
-- Descripción: Obtiene una o varias calles por colonia y calle
-- Generado para formulario: CallesMntto
-- Fecha: 2025-08-27 13:59:54

CREATE OR REPLACE FUNCTION sp_get_calle(p_colonia smallint, p_calle smallint)
RETURNS TABLE(
  colonia smallint,
  calle smallint,
  tipo smallint,
  servicio smallint,
  desc_calle varchar,
  axo_obra smallint,
  cuenta_ingreso integer,
  vigencia_obra varchar,
  id_usuario integer,
  fecha_actual timestamp,
  plazo smallint,
  clave_plazo varchar,
  cuenta_rezago integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT colonia, calle, tipo, servicio, desc_calle, axo_obra, cuenta_ingreso, vigencia_obra, id_usuario, fecha_actual, plazo, clave_plazo, cuenta_rezago
    FROM ta_17_calles
    WHERE colonia = p_colonia AND calle = p_calle;
END;
$$ LANGUAGE plpgsql;