-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: DSCTO_P_PAGO (EXACTO del archivo original)
-- Archivo: 73_SP_ASEO_DSCTO_P_PAGO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_dscto_pp_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de descuento por pronto pago
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_dscto_pp_create(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_porc_dscto NUMERIC,
    p_usuario_mov VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.ta_16_dscto_pp (
        fecha_inicio, fecha_fin, porc_dscto, status, fecha_at, fecha_in, usuario_mov
    ) VALUES (
        p_fecha_inicio, p_fecha_fin, p_porc_dscto, 'V', CURRENT_DATE, CURRENT_DATE, p_usuario_mov
    );
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: DSCTO_P_PAGO (EXACTO del archivo original)
-- Archivo: 73_SP_ASEO_DSCTO_P_PAGO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

