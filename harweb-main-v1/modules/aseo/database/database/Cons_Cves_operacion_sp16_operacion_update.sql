-- Stored Procedure: sp16_operacion_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una clave de operación existente.
-- Generado para formulario: Cons_Cves_operacion
-- Fecha: 2025-08-27 14:00:02

CREATE OR REPLACE FUNCTION sp16_operacion_update(p_ctrol_operacion INT, p_descripcion VARCHAR)
RETURNS TABLE(status INT, leyenda TEXT) AS $$
DECLARE
  existe INT;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
  IF existe = 0 THEN
    RETURN QUERY SELECT 1, 'NO EXISTE LA CLAVE DE OPERACION.';
    RETURN;
  END IF;
  UPDATE ta_16_operacion SET descripcion = p_descripcion WHERE ctrol_operacion = p_ctrol_operacion;
  RETURN QUERY SELECT 0, 'DESCRIPCION ACTUALIZADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;