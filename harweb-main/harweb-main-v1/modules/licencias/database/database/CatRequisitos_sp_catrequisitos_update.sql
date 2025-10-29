-- Stored Procedure: sp_catrequisitos_update
-- Tipo: CRUD
-- Descripción: Actualiza un requisito existente
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-26 15:26:45

CREATE OR REPLACE FUNCTION sp_catrequisitos_update(p_req integer, p_descripcion text)
RETURNS TABLE(req integer, descripcion text) AS $$
BEGIN
  UPDATE cat_requisitos SET descripcion = p_descripcion WHERE req = p_req;
  RETURN QUERY SELECT req, descripcion FROM cat_requisitos WHERE req = p_req;
END;
$$ LANGUAGE plpgsql;