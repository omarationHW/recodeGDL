-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CatRequisitos
-- Generado: 2025-08-27 17:05:51
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_cat_requisitos_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los requisitos del catálogo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_requisitos_list()
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM c_girosreq ORDER BY req;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_cat_requisitos_search
-- Tipo: Catalog
-- Descripción: Busca requisitos por descripción (LIKE).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_requisitos_search(p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE descripcion ILIKE '%' || p_descripcion || '%' ORDER BY req;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_cat_requisitos_create
-- Tipo: CRUD
-- Descripción: Agrega un nuevo requisito al catálogo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_requisitos_create(p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
DECLARE
  new_req integer;
BEGIN
  SELECT COALESCE(MAX(req),0)+1 INTO new_req FROM c_girosreq;
  INSERT INTO c_girosreq(req, descripcion) VALUES (new_req, p_descripcion);
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE req = new_req;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_cat_requisitos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un requisito.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_requisitos_update(p_req integer, p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  UPDATE c_girosreq SET descripcion = p_descripcion WHERE req = p_req;
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE req = p_req;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_cat_requisitos_delete
-- Tipo: CRUD
-- Descripción: Elimina un requisito del catálogo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_requisitos_delete(p_req integer)
RETURNS TABLE(req integer, descripcion varchar) AS $$
DECLARE
  old_desc varchar;
BEGIN
  SELECT descripcion INTO old_desc FROM c_girosreq WHERE req = p_req;
  DELETE FROM c_girosreq WHERE req = p_req;
  RETURN QUERY SELECT p_req, old_desc;
END;
$$ LANGUAGE plpgsql;

-- ============================================

