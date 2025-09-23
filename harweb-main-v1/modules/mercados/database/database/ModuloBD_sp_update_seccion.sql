-- Stored Procedure: sp_update_seccion
-- Tipo: CRUD
-- Descripción: Actualiza una sección existente
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_update_seccion(_seccion varchar, _descripcion varchar)
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_secciones SET descripcion = UPPER(_descripcion) WHERE seccion = UPPER(_seccion);
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones WHERE seccion = UPPER(_seccion);
END; $$;