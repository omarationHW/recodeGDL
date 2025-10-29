-- Stored Procedure: sp_secciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva sección.
-- Generado para formulario: Secciones
-- Fecha: 2025-08-27 01:30:23

CREATE OR REPLACE FUNCTION sp_secciones_create(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
    RETURN QUERY SELECT FALSE, 'La sección ya existe.';
    RETURN;
  END IF;
  INSERT INTO ta_11_secciones(seccion, descripcion) VALUES (UPPER(p_seccion), UPPER(p_descripcion));
  RETURN QUERY SELECT TRUE, 'Sección creada correctamente.';
END;
$$ LANGUAGE plpgsql;