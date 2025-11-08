-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: AdeudosExe_Del (EXACTO del archivo original)
-- Archivo: 22_SP_ASEO_ADEUDOSEXE_DEL_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_adeudos_exe_del_fisica
-- Tipo: CRUD
-- Descripción: Elimina físicamente (DELETE) el registro de pago de un contrato para un periodo y operación específica.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_adeudos_exe_del_fisica(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    OUT p_deleted INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_control_contrato INTEGER;
    v_periodo TEXT;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM public.ta_16_contratos
    WHERE num_contrato = p_contrato AND ctrol_aseo = p_ctrol_aseo;
    IF v_control_contrato IS NULL THEN
        p_deleted := 0;
        RETURN;
    END IF;
    v_periodo := lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0');
    DELETE FROM public.ta_16_pagos
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = v_periodo
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    GET DIAGNOSTICS p_deleted = ROW_COUNT;
END;$$;

-- ============================================

-- SP 2/3: sp_adeudos_exe_del_logica
-- Tipo: CRUD
-- Descripción: Realiza baja lógica (UPDATE status_vigencia = 'B') del registro de pago de un contrato para un periodo y operación específica.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_adeudos_exe_del_logica(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    p_oficio TEXT,
    p_usuario_id INTEGER,
    OUT p_updated INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_control_contrato INTEGER;
    v_periodo TEXT;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM public.ta_16_contratos
    WHERE num_contrato = p_contrato AND ctrol_aseo = p_ctrol_aseo;
    IF v_control_contrato IS NULL THEN
        p_updated := 0;
        RETURN;
    END IF;
    v_periodo := lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0');
    UPDATE public.ta_16_pagos
    SET status_vigencia = 'B', usuario = p_usuario_id, folio_rcbo = p_oficio
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = v_periodo
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    GET DIAGNOSTICS p_updated = ROW_COUNT;
END;$$;

-- ============================================

-- SP 3/3: sp_adeudos_exe_del_list_contrato
-- Tipo: Catalog
-- Descripción: Obtiene los datos básicos del contrato y unidad de recolección para mostrar en el formulario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_exe_del_list_contrato(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    ctrol_recolec INTEGER,
    costo_unidad NUMERIC,
    aso_mes_oblig TEXT
) LANGUAGE sql AS $$
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, b.costo_unidad, a.aso_mes_oblig::text
    FROM public.ta_16_contratos a
    JOIN public.ta_16_unidades b ON a.ctrol_recolec = b.ctrol_recolec
    WHERE a.num_contrato = p_contrato AND a.ctrol_aseo = p_ctrol_aseo;
$$;

-- ============================================