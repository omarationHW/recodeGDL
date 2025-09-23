-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOSMULT_INS (EXACTO del archivo original)
-- Archivo: 44_SP_ASEO_ADEUDOSMULT_INS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_adeudos_mult_ins_insert
-- Tipo: CRUD
-- Descripción: Inserta múltiples excedentes para contratos en un periodo, validando existencia de contrato, cuota normal y ausencia de excedente previo.
-- --------------------------------------------

--
-- sp_adeudos_mult_ins_insert
-- Inserta múltiples excedentes para contratos en un periodo
-- Params: p_anio integer, p_mes text, p_tipo_aseo integer, p_tipo_oper integer, p_oficio text, p_user_id integer, p_rows jsonb
CREATE OR REPLACE FUNCTION sp_adeudos_mult_ins_insert(
    p_anio integer,
    p_mes text,
    p_tipo_aseo integer,
    p_tipo_oper integer,
    p_oficio text,
    p_user_id integer,
    p_rows jsonb
) RETURNS TABLE(
    contrato integer,
    status text,
    mensaje text
) AS $$
DECLARE
    r jsonb;
    v_contrato integer;
    v_excedencia integer;
    v_control_contrato integer;
    v_costo_exed numeric;
    v_cuota_normal integer;
    v_exed integer;
BEGIN
    FOR r IN SELECT * FROM jsonb_array_elements(p_rows) LOOP
        v_contrato := (r->>'contrato')::integer;
        v_excedencia := (r->>'excedencia')::integer;
        -- Buscar contrato y costo_exed
        SELECT a.control_contrato, c.costo_exed INTO v_control_contrato, v_costo_exed
        FROM public.ta_16_contratos a
        JOIN public.ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
        JOIN public.ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_anio
        WHERE a.num_contrato = v_contrato AND a.ctrol_aseo = p_tipo_aseo;
        IF v_control_contrato IS NULL THEN
            contrato := v_contrato;
            status := 'ERROR';
            mensaje := 'Contrato no existe o no corresponde al tipo de aseo';
            RETURN NEXT;
            CONTINUE;
        END IF;
        -- Verificar cuota normal
        SELECT 1 INTO v_cuota_normal FROM public.ta_16_pagos WHERE control_contrato = v_control_contrato AND aso_mes_pago = p_anio||'-'||p_mes AND ctrol_operacion = 6 AND (status_vigencia = 'V' OR status_vigencia = 'P') LIMIT 1;
        IF v_cuota_normal IS NULL THEN
            contrato := v_contrato;
            status := 'ERROR';
            mensaje := 'No existe cuota normal para el periodo';
            RETURN NEXT;
            CONTINUE;
        END IF;
        -- Verificar si ya existe excedente
        SELECT 1 INTO v_exed FROM public.ta_16_pagos WHERE control_contrato = v_control_contrato AND aso_mes_pago = p_anio||'-'||p_mes AND ctrol_operacion = p_tipo_oper LIMIT 1;
        IF v_exed IS NOT NULL THEN
            contrato := v_contrato;
            status := 'ERROR';
            mensaje := 'Ya existe excedente para el periodo';
            RETURN NEXT;
            CONTINUE;
        END IF;
        -- Insertar nuevo excedente
        INSERT INTO public.ta_16_pagos (control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, fecha_hora_pago, id_rec, caja, consec_operacion, folio_rcbo, usuario, exedencias)
        VALUES (v_control_contrato, p_anio||'-'||p_mes, p_tipo_oper, v_excedencia * v_costo_exed, 'V', CURRENT_TIMESTAMP, 0, '', 0, p_oficio, p_user_id, v_excedencia);
        contrato := v_contrato;
        status := 'OK';
        mensaje := 'Excedente insertado';
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

