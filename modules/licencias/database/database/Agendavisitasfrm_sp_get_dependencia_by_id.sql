-- Stored Procedure: sp_get_dependencia_by_id
-- Tipo: Catalog
-- Descripción: Devuelve la información de una dependencia específica por su ID.
-- Generado para formulario: Agendavisitasfrm
-- Fecha: 2025-08-26 14:27:50

CREATE OR REPLACE FUNCTION sp_get_dependencia_by_id(p_id_dependencia integer)
RETURNS TABLE(id_dependencia integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id_dependencia, descripcion
    FROM c_dependencias
    WHERE id_dependencia = p_id_dependencia;
END;
$$;