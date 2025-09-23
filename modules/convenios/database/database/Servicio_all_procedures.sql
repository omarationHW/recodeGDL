-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Servicio
-- Generado: 2025-08-27 15:53:18
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_servicio_list
-- Tipo: Catalog
-- Descripción: Lista todos los servicios de obra pública
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_list()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios ORDER BY servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_servicio_show
-- Tipo: Catalog
-- Descripción: Obtiene un servicio por ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_show(p_servicio smallint)
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_servicio_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo servicio de obra pública
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_create(p_descripcion varchar, p_serv_obra94 smallint)
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
DECLARE
  new_id smallint;
BEGIN
  SELECT COALESCE(MAX(servicio), 0) + 1 INTO new_id FROM ta_17_servicios;
  INSERT INTO ta_17_servicios(servicio, descripcion, serv_obra94)
    VALUES (new_id, p_descripcion, p_serv_obra94)
    RETURNING servicio, descripcion, serv_obra94 INTO new_id, p_descripcion, p_serv_obra94;
  RETURN QUERY SELECT new_id, p_descripcion, p_serv_obra94;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_servicio_update
-- Tipo: CRUD
-- Descripción: Actualiza un servicio de obra pública
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_update(p_servicio smallint, p_descripcion varchar, p_serv_obra94 smallint)
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  UPDATE ta_17_servicios
    SET descripcion = p_descripcion,
        serv_obra94 = p_serv_obra94
    WHERE servicio = p_servicio;
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_servicio_delete
-- Tipo: CRUD
-- Descripción: Elimina un servicio de obra pública
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_delete(p_servicio smallint)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  DELETE FROM ta_17_servicios WHERE servicio = p_servicio;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Servicio eliminado correctamente';
  ELSE
    RETURN QUERY SELECT FALSE, 'Servicio no encontrado';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_servicio_report
-- Tipo: Report
-- Descripción: Reporte de catálogo de servicios (para impresión)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_report()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM ta_17_servicios ORDER BY servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

