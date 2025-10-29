-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SERVICIO (EXACTO del archivo original)
-- Archivo: 88_SP_CONVENIOS_SERVICIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_servicio_list
-- Tipo: Catalog
-- Descripción: Lista todos los servicios de obra pública
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_list()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM public.ta_17_servicios ORDER BY servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SERVICIO (EXACTO del archivo original)
-- Archivo: 88_SP_CONVENIOS_SERVICIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
  SELECT COALESCE(MAX(servicio), 0) + 1 INTO new_id FROM public.ta_17_servicios;
  INSERT INTO public.ta_17_servicios(servicio, descripcion, serv_obra94)
    VALUES (new_id, p_descripcion, p_serv_obra94)
    RETURNING servicio, descripcion, serv_obra94 INTO new_id, p_descripcion, p_serv_obra94;
  RETURN QUERY SELECT new_id, p_descripcion, p_serv_obra94;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SERVICIO (EXACTO del archivo original)
-- Archivo: 88_SP_CONVENIOS_SERVICIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_servicio_delete
-- Tipo: CRUD
-- Descripción: Elimina un servicio de obra pública
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicio_delete(p_servicio smallint)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  DELETE FROM public.ta_17_servicios WHERE servicio = p_servicio;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Servicio eliminado correctamente';
  ELSE
    RETURN QUERY SELECT FALSE, 'Servicio no encontrado';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SERVICIO (EXACTO del archivo original)
-- Archivo: 88_SP_CONVENIOS_SERVICIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

