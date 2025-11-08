-- Stored Procedure: sp_secciones_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una sección existente.
-- Generado para formulario: Secciones
-- Fecha: 2025-08-27 01:30:23

CREATE OR REPLACE FUNCTION sp_secciones_update(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
    RETURN QUERY SELECT FALSE, 'La sección no existe.';
    RETURN;
  END IF;
  UPDATE ta_11_secciones SET descripcion = UPPER(p_descripcion) WHERE seccion = p_seccion;
  RETURN QUERY SELECT TRUE, 'Sección actualizada correctamente.';
END;
$$ LANGUAGE plpgsql;