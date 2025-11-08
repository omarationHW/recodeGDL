-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOSCN_COND (EXACTO del archivo original)
-- Archivo: 41_SP_ASEO_ADEUDOSCN_COND_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp16_condona_adeudo
-- Tipo: CRUD
-- Descripción: Condona (marca como condonado) un adeudo de exedencia vigente para un contrato, periodo y tipo de operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_condona_adeudo(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso_mes_pago VARCHAR,
    p_ctrol_operacion INTEGER,
    p_oficio VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_control_contrato INTEGER;
    v_count INTEGER;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM public.ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
    IF v_control_contrato IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el contrato.';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_count
    FROM public.ta_16_pagos
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    IF v_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe EXEDENCIA vigente para condonar.';
        RETURN;
    END IF;
    UPDATE public.ta_16_pagos
    SET status_vigencia = 'S',
        fecha_hora_pago = NOW(),
        usuario = p_usuario,
        folio_rcbo = p_oficio
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    RETURN QUERY SELECT TRUE, 'Condonación realizada correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

