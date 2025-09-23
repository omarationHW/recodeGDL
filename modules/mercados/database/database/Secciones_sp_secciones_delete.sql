-- Stored Procedure: sp_secciones_delete
-- Tipo: CRUD
-- Descripción: Elimina una sección por clave.
-- Generado para formulario: Secciones
-- Fecha: 2025-08-27 01:30:23

CREATE OR REPLACE FUNCTION sp_secciones_delete(p_seccion VARCHAR(2))
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
    RETURN QUERY SELECT FALSE, 'La sección no existe.';
    RETURN;
  END IF;
  DELETE FROM ta_11_secciones WHERE seccion = p_seccion;
  RETURN QUERY SELECT TRUE, 'Sección eliminada correctamente.';
END;
$$ LANGUAGE plpgsql;