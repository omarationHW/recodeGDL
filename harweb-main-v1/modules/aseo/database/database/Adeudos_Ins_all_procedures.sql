-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Adeudos_Ins
-- Generado: 2025-08-27 13:44:07
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_adeudos_ins_insert
-- Tipo: CRUD
-- Descripción: Inserta una exedencia/contenedor en ta_16_pagos con validaciones de negocio.
-- --------------------------------------------

-- PostgreSQL stored procedure for inserting exedencia/contenedor
CREATE OR REPLACE FUNCTION sp_adeudos_ins_insert(
    p_num_contrato integer,
    p_ctrol_aseo integer,
    p_ejercicio integer,
    p_aso integer,
    p_mes varchar,
    p_ctrol_operacion integer,
    p_exedencias integer,
    p_oficio varchar,
    p_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_control_contrato integer;
    v_costo_exed numeric;
    v_aso_mes_oblig date;
    v_fecha_cap date;
    v_importe numeric;
    v_exists integer;
    v_ejercicio_actual integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    -- Validar contrato
    SELECT control_contrato, costo_exed, aso_mes_oblig INTO v_control_contrato, v_costo_exed, v_aso_mes_oblig
    FROM ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo AND EXTRACT(YEAR FROM aso_mes_oblig) <= p_aso;
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Contrato no encontrado o fuera de rango de ejercicio';
        RETURN;
    END IF;
    v_fecha_cap := TO_DATE(p_aso || '-' || LPAD(p_mes,2,'0') || '-01', 'YYYY-MM-DD');
    IF v_fecha_cap < v_aso_mes_oblig THEN
        RETURN QUERY SELECT false, 'La fecha de exedencia es menor al inicio de obligación';
        RETURN;
    END IF;
    -- Validar cuota normal
    SELECT 1 INTO v_exists FROM ta_16_pagos WHERE control_contrato = v_control_contrato AND aso_mes_pago = v_fecha_cap AND ctrol_operacion = 6 AND (status_vigencia = 'V' OR status_vigencia = 'P') LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'No existe cuota normal para el periodo';
        RETURN;
    END IF;
    -- Validar que no exista exedencia
    SELECT 1 INTO v_exists FROM ta_16_pagos WHERE control_contrato = v_control_contrato AND aso_mes_pago = v_fecha_cap AND ctrol_operacion = p_ctrol_operacion AND status_vigencia <> 'Z' LIMIT 1;
    IF FOUND THEN
        RETURN QUERY SELECT false, 'Ya existe exedencia/contenedor para este periodo';
        RETURN;
    END IF;
    -- Validar rango de año
    IF p_aso < 1989 OR p_aso > v_ejercicio_actual THEN
        RETURN QUERY SELECT false, 'Año fuera de rango permitido';
        RETURN;
    END IF;
    -- Insertar
    v_importe := p_exedencias * v_costo_exed;
    INSERT INTO ta_16_pagos (
        control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, fecha_hora_pago, id_rec, caja, consec_operacion, folio_rcbo, usuario, exedencias
    ) VALUES (
        v_control_contrato, v_fecha_cap, p_ctrol_operacion, v_importe, 'V', NOW(), 0, '', 0, COALESCE(p_oficio, '0'), p_usuario, p_exedencias
    );
    RETURN QUERY SELECT true, 'Exedencia registrada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_adeudos_ins_validate_contrato
-- Tipo: CRUD
-- Descripción: Valida que el contrato exista, esté vigente y el año sea válido.
-- --------------------------------------------

-- PostgreSQL stored procedure for validating contrato
CREATE OR REPLACE FUNCTION sp_adeudos_ins_validate_contrato(
    p_num_contrato integer,
    p_ctrol_aseo integer,
    p_ejercicio integer
) RETURNS TABLE(success boolean, message text, contrato_id integer) AS $$
DECLARE
    v_control_contrato integer;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo AND status_vigencia = 'V' AND EXTRACT(YEAR FROM aso_mes_oblig) <= p_ejercicio;
    IF FOUND THEN
        RETURN QUERY SELECT true, '', v_control_contrato;
    ELSE
        RETURN QUERY SELECT false, 'Contrato no encontrado o no vigente', NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_adeudos_ins_get_catalogs
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de tipo de aseo, tipo de operación y meses.
-- --------------------------------------------

-- PostgreSQL stored procedure for getting catalogs
CREATE OR REPLACE FUNCTION sp_adeudos_ins_get_catalogs()
RETURNS TABLE(tipo_aseo jsonb, tipo_operacion jsonb, meses jsonb) AS $$
BEGIN
    RETURN QUERY SELECT
        (SELECT jsonb_agg(row_to_json(t)) FROM (SELECT ctrol_aseo, tipo_aseo, descripcion FROM cat_tipo_aseo ORDER BY ctrol_aseo) t),
        (SELECT jsonb_agg(row_to_json(t)) FROM (SELECT ctrol_operacion, cve_operacion, descripcion FROM cat_operacion WHERE ctrol_operacion > 6 ORDER BY ctrol_operacion) t),
        '[{"value":"01","label":"Enero"},{"value":"02","label":"Febrero"},{"value":"03","label":"Marzo"},{"value":"04","label":"Abril"},{"value":"05","label":"Mayo"},{"value":"06","label":"Junio"},{"value":"07","label":"Julio"},{"value":"08","label":"Agosto"},{"value":"09","label":"Septiembre"},{"value":"10","label":"Octubre"},{"value":"11","label":"Noviembre"},{"value":"12","label":"Diciembre"}]'::jsonb;
END;
$$ LANGUAGE plpgsql;

-- ============================================

