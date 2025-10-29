-- Stored Procedure: sp_catrequisitos_delete
-- Tipo: CRUD
-- Descripción: Elimina un requisito del catálogo
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-26 15:26:45

CREATE OR REPLACE FUNCTION sp_catrequisitos_delete(p_req integer)
RETURNS void AS $$
BEGIN
  DELETE FROM cat_requisitos WHERE req = p_req;
END;
$$ LANGUAGE plpgsql;