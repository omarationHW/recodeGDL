-- Stored Procedure: sp16_operacion_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de operación en ta_16_operacion, validando unicidad de clave y descripción.
-- Generado para formulario: Cons_Cves_operacion
-- Fecha: 2025-08-27 14:00:02

CREATE OR REPLACE FUNCTION sp16_operacion_create(p_cve_operacion VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(status INT, leyenda TEXT) AS $$
DECLARE
  existe INT;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE cve_operacion = p_cve_operacion OR descripcion = p_descripcion;
  IF existe > 0 OR p_cve_operacion IS NULL OR p_descripcion IS NULL OR trim(p_cve_operacion) = '' OR trim(p_descripcion) = '' THEN
    RETURN QUERY SELECT 1, 'YA EXISTE O EL CAMPO DE CLAVE ES NULO, INTENTA CON OTRO.';
    RETURN;
  END IF;
  INSERT INTO ta_16_operacion (cve_operacion, descripcion) VALUES (p_cve_operacion, p_descripcion);
  RETURN QUERY SELECT 0, 'NUEVA CLAVE CREADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;