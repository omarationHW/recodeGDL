-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: Adeudos_Pag (EXACTO del archivo original)
-- Archivo: 28_SP_ASEO_ADEUDOS_PAG_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_adeudos_pag_ver_adeudos
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos (cuota normal y excedencias) para un contrato, tipo de aseo, año y mes.
-- --------------------------------------------

-- PostgreSQL
CREATE OR REPLACE FUNCTION sp_adeudos_pag_ver_adeudos(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER
)
RETURNS TABLE(
    tipo_operacion TEXT,
    exedencias SMALLINT,
    importe NUMERIC,
    status_vigencia TEXT,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja TEXT,
    consec_operacion INTEGER,
    folio_rcbo TEXT
) AS $$
BEGIN
    -- Cuota Normal
    RETURN QUERY
    SELECT 'CN' AS tipo_operacion, a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, a.caja, a.consec_operacion, a.folio_rcbo
    FROM public.ta_16_contratos c
    JOIN public.ta_16_pagos a ON a.control_contrato = c.control_contrato
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND to_char(a.aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
      AND a.ctrol_operacion = (SELECT ctrol_operacion FROM public.ta_16_operacion WHERE cve_operacion = 'C' LIMIT 1)
      AND (a.status_vigencia = 'V' OR a.status_vigencia = 'P');
    -- Excedencias
    RETURN QUERY
    SELECT 'EXE' AS tipo_operacion, a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, a.caja, a.consec_operacion, a.folio_rcbo
    FROM public.ta_16_contratos c
    JOIN public.ta_16_pagos a ON a.control_contrato = c.control_contrato
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND to_char(a.aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
      AND a.ctrol_operacion = (SELECT ctrol_operacion FROM public.ta_16_operacion WHERE cve_operacion = 'E' LIMIT 1)
      AND (a.status_vigencia = 'V' OR a.status_vigencia = 'P');
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_adeudos_pag_ejecutar_pago
-- Tipo: CRUD
-- Descripción: Marca como pagado los adeudos seleccionados (cuota normal y/o excedencias) para un contrato y periodo.
-- --------------------------------------------

-- PostgreSQL
CREATE OR REPLACE FUNCTION sp_adeudos_pag_ejecutar_pago(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_consec_oper INTEGER,
    p_folio_rcbo TEXT,
    p_fecha_pagado DATE,
    p_id_rec INTEGER,
    p_caja TEXT,
    p_usuario_id INTEGER,
    p_pagar_cn BOOLEAN,
    p_importe_cn NUMERIC,
    p_pagar_exe BOOLEAN,
    p_importe_exe NUMERIC
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_control_contrato INTEGER;
    v_ctrol_oper_cn INTEGER;
    v_ctrol_oper_exe INTEGER;
    v_rows INTEGER;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM public.ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No existe contrato con los datos proporcionados.';
        RETURN;
    END IF;
    SELECT ctrol_operacion INTO v_ctrol_oper_cn FROM public.ta_16_operacion WHERE cve_operacion = 'C' LIMIT 1;
    SELECT ctrol_operacion INTO v_ctrol_oper_exe FROM public.ta_16_operacion WHERE cve_operacion = 'E' LIMIT 1;
    IF p_pagar_cn THEN
        UPDATE public.ta_16_pagos SET
            importe = p_importe_cn,
            status_vigencia = 'P',
            fecha_hora_pago = p_fecha_pagado,
            id_rec = p_id_rec,
            caja = p_caja,
            consec_operacion = p_consec_oper,
            folio_rcbo = p_folio_rcbo,
            usuario = p_usuario_id
        WHERE control_contrato = v_control_contrato
          AND to_char(aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
          AND ctrol_operacion = v_ctrol_oper_cn
          AND status_vigencia = 'V';
        GET DIAGNOSTICS v_rows = ROW_COUNT;
        IF v_rows = 0 THEN
            RETURN QUERY SELECT FALSE, 'No se encontró adeudo de cuota normal vigente para pagar.';
            RETURN;
        END IF;
    END IF;
    IF p_pagar_exe THEN
        UPDATE public.ta_16_pagos SET
            importe = p_importe_exe,
            status_vigencia = 'P',
            fecha_hora_pago = p_fecha_pagado,
            id_rec = p_id_rec,
            caja = p_caja,
            consec_operacion = p_consec_oper,
            folio_rcbo = p_folio_rcbo,
            usuario = p_usuario_id
        WHERE control_contrato = v_control_contrato
          AND to_char(aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
          AND ctrol_operacion = v_ctrol_oper_exe
          AND status_vigencia = 'V';
        GET DIAGNOSTICS v_rows = ROW_COUNT;
        IF v_rows = 0 THEN
            RETURN QUERY SELECT FALSE, 'No se encontró adeudo de excedencias vigente para pagar.';
            RETURN;
        END IF;
    END IF;
    RETURN QUERY SELECT TRUE, 'Pago realizado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================