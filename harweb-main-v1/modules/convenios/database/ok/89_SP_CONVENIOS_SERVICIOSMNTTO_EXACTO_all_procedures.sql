-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SERVICIOSMNTTO (EXACTO del archivo original)
-- Archivo: 89_SP_CONVENIOS_SERVICIOSMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_servicios_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en ta_17_servicios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicios_insert(p_servicio integer, p_descripcion text, p_serv_obra94 integer)
RETURNS TABLE(servicio integer, descripcion text, serv_obra94 integer) AS $$
BEGIN
    INSERT INTO public.ta_17_servicios(servicio, descripcion, serv_obra94)
    VALUES (p_servicio, p_descripcion, p_serv_obra94);
    RETURN QUERY SELECT servicio, descripcion, serv_obra94 FROM public.ta_17_servicios WHERE servicio = p_servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: SERVICIOSMNTTO (EXACTO del archivo original)
-- Archivo: 89_SP_CONVENIOS_SERVICIOSMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_servicios_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_17_servicios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_servicios_delete(p_servicio integer)
RETURNS TABLE(success boolean) AS $$
BEGIN
    DELETE FROM public.ta_17_servicios WHERE servicio = p_servicio;
    RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

