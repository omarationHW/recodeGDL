-- Stored Procedure: sp_pasoene_insert_pagoenergia
-- Tipo: CRUD
-- Descripción: Inserta un registro de pago de energía en la tabla ta_11_pago_energia. Valida tipos y formato de fecha.
-- Generado para formulario: PasoEne
-- Fecha: 2025-08-27 00:28:43

CREATE OR REPLACE PROCEDURE sp_pasoene_insert_pagoenergia(
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
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_pago DATE;
    v_fecha_actualizacion TIMESTAMP;
BEGIN
    BEGIN
        v_fecha_pago := to_date(p_fecha_pago, 'DD/MM/YYYY');
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Formato de fecha_pago inválido: %', p_fecha_pago;
    END;
    BEGIN
        v_fecha_actualizacion := to_timestamp(p_fecha_actualizacion, 'YYYY-MM-DD HH24:MI:SS');
    EXCEPTION WHEN OTHERS THEN
        v_fecha_actualizacion := now();
    END;
    INSERT INTO ta_11_pago_energia (
        id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    ) VALUES (
        DEFAULT, p_id_energia, p_axo, p_periodo, v_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_consumo, p_cantidad, p_folio, v_fecha_actualizacion, p_id_usuario
    );
END;
$$;