-- Stored Procedure: sp_cargar_pago_energia
-- Tipo: CRUD
-- Descripción: Carga un pago de energía eléctrica y elimina el adeudo correspondiente.
-- Generado para formulario: CargaPagEnergia
-- Fecha: 2025-08-26 22:51:22

CREATE OR REPLACE FUNCTION sp_cargar_pago_energia(
    p_id_energia INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_fecha_pago DATE,
    p_oficina_pago INTEGER,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER,
    p_importe NUMERIC,
    p_cve_consumo VARCHAR,
    p_cantidad NUMERIC,
    p_folio VARCHAR,
    p_id_usuario INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO ta_11_pago_energia (
        id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    ) VALUES (
        DEFAULT, p_id_energia, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe, p_cve_consumo, p_cantidad, p_folio, NOW(), p_id_usuario
    );
    DELETE FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;