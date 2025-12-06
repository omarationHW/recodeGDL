-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PasoEne
-- Generado: 2025-08-27 00:28:43
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_pasoene_insert_pagoenergia
-- Tipo: CRUD
-- Descripción: Inserta un registro de pago de energía en la tabla ta_11_pago_energia. Valida tipos y formato de fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pasoene_insert_pagoenergia(
    p_id_energia INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_fecha_pago VARCHAR,
    p_oficina_pago INTEGER,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER,
    p_importe_pago NUMERIC,
    p_consumo VARCHAR,
    p_cantidad NUMERIC,
    p_folio VARCHAR,
    p_fecha_actualizacion VARCHAR,
    p_id_usuario INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT, id_pago_energia INTEGER) AS $$
DECLARE
    v_fecha_pago DATE;
    v_fecha_actualizacion TIMESTAMP;
    v_id_pago_energia INTEGER;
BEGIN
    BEGIN
        v_fecha_pago := to_date(p_fecha_pago, 'DD/MM/YYYY');
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Formato de fecha_pago inválido: ' || p_fecha_pago, NULL::INTEGER;
        RETURN;
    END;
    BEGIN
        v_fecha_actualizacion := to_timestamp(p_fecha_actualizacion, 'YYYY-MM-DD HH24:MI:SS');
    EXCEPTION WHEN OTHERS THEN
        v_fecha_actualizacion := now();
    END;
    INSERT INTO padron_licencias.comun.ta_11_pago_energia (
        id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    ) VALUES (
        p_id_energia, p_axo, p_periodo, v_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_consumo, p_cantidad, p_folio, v_fecha_actualizacion, p_id_usuario
    ) RETURNING padron_licencias.comun.ta_11_pago_energia.id_pago_energia INTO v_id_pago_energia;

    RETURN QUERY SELECT true, 'Pago de energía registrado exitosamente', v_id_pago_energia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

