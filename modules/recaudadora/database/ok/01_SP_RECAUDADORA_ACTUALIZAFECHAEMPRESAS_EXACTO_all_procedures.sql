-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: ActualizaFechaEmpresas (EXACTO del archivo original)
-- Archivo: 01_SP_RECAUDADORA_ACTUALIZAFECHAEMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_actualiza_fecha_practica
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de práctica (fecent) de un folio de requerimiento de empresa
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_actualiza_fecha_practica(
    IN p_cvereq INTEGER,
    IN p_fecha_practica DATE
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.reqpredial
    SET fecent = p_fecha_practica
    WHERE cvereq = p_cvereq;
END;
$$;

-- ============================================