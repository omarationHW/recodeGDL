-- Stored Procedure: sp_insert_calle
-- Tipo: CRUD
-- Descripción: Inserta una nueva calle en el catálogo
-- Generado para formulario: CallesMntto
-- Fecha: 2025-08-27 13:59:54

CREATE OR REPLACE FUNCTION sp_insert_calle(
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
  INSERT INTO ta_17_calles (
    colonia, calle, tipo, servicio, desc_calle, axo_obra, cuenta_ingreso, vigencia_obra, id_usuario, fecha_actual, plazo, clave_plazo, cuenta_rezago
  ) VALUES (
    p_colonia, p_calle, p_tipo, p_servicio, p_desc_calle, p_axo_obra, p_cuenta_ingreso, p_vigencia_obra, p_id_usuario, CURRENT_TIMESTAMP, p_plazo, p_clave_plazo, p_cuenta_rezago
  );
  RETURN QUERY SELECT true, 'Calle insertada correctamente';
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT false, 'Error al insertar la calle: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;