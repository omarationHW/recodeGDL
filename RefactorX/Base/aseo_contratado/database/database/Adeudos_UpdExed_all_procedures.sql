-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Adeudos_UpdExed
-- Base de datos: aseo_contratado
-- Tabla principal: ta_16_pagos, ta_16_contratos
-- Actualizado: 2025-12-07
-- Total SPs: 6 (3 legacy + 3 nuevos)
-- ============================================
-- Descripción: Actualización de cantidad e importe de exedencias vigentes
-- Flujo Delphi Original:
--   1. Buscar contrato con costo_exed
--   2. Buscar exedencia vigente en ta_16_pagos
--   3. Actualizar: Importe = unidades * costo_exed
-- ============================================

-- ============================================
-- SPs LEGACY (anteriores)
-- ============================================

-- SP Legacy 1/3: sp_adeudos_updexed_search
-- Tipo: CRUD
-- Descripción: Busca la excedencia vigente para un contrato, periodo y tipo de operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_updexed_search(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_ejercicio INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    ctrol_recolec INTEGER,
    costo_exed NUMERIC,
    aso_mes_oblig DATE,
    exedencias INTEGER,
    importe NUMERIC,
    aso_mes_pago VARCHAR,
    status_vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, c.costo_exed, a.aso_mes_oblig,
           p.exedencias, p.importe, p.aso_mes_pago, p.status_vigencia
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_ejercicio
    JOIN ta_16_pagos p ON p.control_contrato = a.control_contrato
        AND p.aso_mes_pago = lpad(p_ejercicio::text,4,'0')||'-'||lpad(p_mes::text,2,'0')
        AND p.ctrol_operacion = p_ctrol_operacion
        AND p.status_vigencia = 'V'
    WHERE a.num_contrato = p_num_contrato AND a.ctrol_aseo = p_ctrol_aseo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP Legacy 2/3: sp_adeudos_updexed_update
-- Tipo: CRUD
-- Descripción: Actualiza la cantidad de excedencias y el importe para un registro vigente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_updexed_update(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_ejercicio INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    p_cantidad INTEGER,
    p_oficio VARCHAR,
    p_usuario INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_control_contrato INTEGER;
    v_costo_exed NUMERIC;
    v_periodo VARCHAR;
    v_affected INTEGER;
BEGIN
    SELECT a.control_contrato, c.costo_exed
    INTO v_control_contrato, v_costo_exed
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_ejercicio
    WHERE a.num_contrato = p_num_contrato AND a.ctrol_aseo = p_ctrol_aseo
    LIMIT 1;
    IF v_control_contrato IS NULL THEN
        RAISE EXCEPTION 'Contrato no encontrado';
    END IF;
    v_periodo := lpad(p_ejercicio::text,4,'0')||'-'||lpad(p_mes::text,2,'0');
    UPDATE ta_16_pagos
    SET importe = p_cantidad * v_costo_exed,
        folio_rcbo = p_oficio,
        usuario = p_usuario,
        exedencias = p_cantidad
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = v_periodo
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    GET DIAGNOSTICS v_affected = ROW_COUNT;
    RETURN v_affected;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP Legacy 3/3: sp_adeudos_updexed_catalogs
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de tipos de aseo, tipos de operación y meses.
-- --------------------------------------------

-- No es un SP, pero para uniformidad:
-- SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
-- SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion WHERE ctrol_operacion > 6 ORDER BY ctrol_operacion;

-- ============================================
-- SPs NUEVOS (apegados al Delphi original) - 2025-12-07
-- ============================================

-- SP Nuevo 1/3: sp_aseo_contrato_buscar_con_costo_exed
-- Descripción: Busca contrato por número, tipo aseo y ejercicio, retornando costo_exed
-- Parámetros:
--   p_num_contrato: Número del contrato
--   p_ctrol_aseo: Control de tipo de aseo
--   p_ejercicio: Año del ejercicio
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_contrato_buscar_con_costo_exed(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_contrato_buscar_con_costo_exed(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_ejercicio INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    ctrol_recolec INTEGER,
    costo_exed NUMERIC,
    aso_mes_oblig TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.control_contrato, c.num_contrato, c.ctrol_aseo, c.ctrol_recolec,
           c.costo_exed, c.aso_mes_oblig
    FROM ta_16_contratos c
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND EXTRACT(YEAR FROM c.aso_mes_oblig) = p_ejercicio;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_contrato_buscar_con_costo_exed(INTEGER, INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- SP Nuevo 2/3: sp_aseo_buscar_exedencia_vigente
-- Descripción: Busca exedencia vigente en ta_16_pagos
-- Parámetros:
--   p_control_contrato: Control del contrato
--   p_aso_mes_pago: Periodo en formato YYYY-MM
--   p_ctrol_operacion: Control de tipo de operación
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_buscar_exedencia_vigente(INTEGER, VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_exedencia_vigente(
    p_control_contrato INTEGER,
    p_aso_mes_pago VARCHAR,
    p_ctrol_operacion INTEGER
)
RETURNS TABLE (
    control_pago INTEGER,
    control_contrato INTEGER,
    aso_mes_pago VARCHAR,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    exedencias INTEGER,
    folio_rcbo VARCHAR,
    status_vigencia CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.control_pago, p.control_contrato,
           TO_CHAR(p.aso_mes_pago, 'YYYY-MM')::VARCHAR as aso_mes_pago,
           p.ctrol_operacion, p.importe,
           COALESCE(p.exedencias, 0)::INTEGER as exedencias,
           p.folio_rcbo::VARCHAR, p.status_vigencia
    FROM ta_16_pagos p
    WHERE p.control_contrato = p_control_contrato
      AND TO_CHAR(p.aso_mes_pago, 'YYYY-MM') = p_aso_mes_pago
      AND p.ctrol_operacion = p_ctrol_operacion
      AND p.status_vigencia = 'V';
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_buscar_exedencia_vigente(INTEGER, VARCHAR, INTEGER) TO PUBLIC;

-- ============================================
-- SP Nuevo 3/3: sp_aseo_actualizar_exedencia
-- Descripción: Actualiza exedencia vigente
-- Parámetros:
--   p_control_contrato: Control del contrato
--   p_aso_mes_pago: Periodo en formato YYYY-MM
--   p_ctrol_operacion: Control de tipo de operación
--   p_unidades: Nueva cantidad de exedencias
--   p_oficio: Número de oficio de autorización
--   p_usuario: ID del usuario que realiza la actualización
--   p_costo_exed: Costo por exedencia del contrato
-- Fórmula: Importe = p_unidades * p_costo_exed
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_actualizar_exedencia(INTEGER, VARCHAR, INTEGER, INTEGER, VARCHAR, INTEGER, NUMERIC);

CREATE OR REPLACE FUNCTION public.sp_aseo_actualizar_exedencia(
    p_control_contrato INTEGER,
    p_aso_mes_pago VARCHAR,
    p_ctrol_operacion INTEGER,
    p_unidades INTEGER,
    p_oficio VARCHAR,
    p_usuario INTEGER,
    p_costo_exed NUMERIC
)
RETURNS TABLE (success BOOLEAN, message TEXT, registros_afectados INTEGER) AS $$
DECLARE
    v_importe NUMERIC;
    v_affected INTEGER;
BEGIN
    -- Calcular importe = unidades * costo_exed
    v_importe := p_unidades * p_costo_exed;

    -- Actualizar exedencia vigente
    UPDATE ta_16_pagos
    SET importe = v_importe,
        folio_rcbo = p_oficio,
        usuario = p_usuario,
        exedencias = p_unidades
    WHERE control_contrato = p_control_contrato
      AND TO_CHAR(aso_mes_pago, 'YYYY-MM') = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected > 0 THEN
        RETURN QUERY SELECT true, ('Exedencia actualizada correctamente. Importe: ' || v_importe::TEXT)::TEXT, v_affected;
    ELSE
        RETURN QUERY SELECT false, 'No se encontró exedencia vigente para actualizar'::TEXT, 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_actualizar_exedencia(INTEGER, VARCHAR, INTEGER, INTEGER, VARCHAR, INTEGER, NUMERIC) TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
