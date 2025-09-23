-- Stored Procedure: sp_update_calle
-- Tipo: CRUD
-- Descripción: Actualiza una calle existente en el catálogo
-- Generado para formulario: CallesMntto
-- Fecha: 2025-08-27 13:59:54

CREATE OR REPLACE FUNCTION sp_update_calle(
  p_colonia smallint,
  p_calle smallint,
  p_tipo smallint,
  p_servicio smallint,
  p_desc_calle varchar,
  p_axo_obra smallint,
  p_cuenta_ingreso integer,
  p_vigencia_obra varchar,
  p_id_usuario integer,
  p_plazo smallint,
  p_clave_plazo varchar,
  p_cuenta_rezago integer
) RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE ta_17_calles SET
    tipo = p_tipo,
    servicio = p_servicio,
    desc_calle = p_desc_calle,
    axo_obra = p_axo_obra,
    cuenta_ingreso = p_cuenta_ingreso,
    vigencia_obra = p_vigencia_obra,
    id_usuario = p_id_usuario,
    fecha_actual = CURRENT_TIMESTAMP,
    plazo = p_plazo,
    clave_plazo = p_clave_plazo,
    cuenta_rezago = p_cuenta_rezago
  WHERE colonia = p_colonia AND calle = p_calle;
  IF FOUND THEN
    RETURN QUERY SELECT true, 'Calle actualizada correctamente';
  ELSE
    RETURN QUERY SELECT false, 'No se encontró la calle para actualizar';
  END IF;
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT false, 'Error al actualizar la calle: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;