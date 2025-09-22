-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTSERVICIOS (EXACTO del archivo original)
-- Archivo: 87_SP_CONVENIOS_RPTSERVICIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: rptservicios_get_all
-- Tipo: Report
-- Descripción: Obtiene todos los registros del catálogo de servicios, ordenados por servicio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptservicios_get_all()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT servicio, descripcion, serv_obra94
    FROM public.ta_17_servicios
    ORDER BY servicio;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTSERVICIOS (EXACTO del archivo original)
-- Archivo: 87_SP_CONVENIOS_RPTSERVICIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

