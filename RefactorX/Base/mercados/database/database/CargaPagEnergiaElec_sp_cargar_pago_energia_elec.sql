-- Stored Procedure: sp_cargar_pago_energia_elec
-- Tipo: CRUD
-- Descripción: Carga un pago de energía eléctrica y elimina el adeudo correspondiente
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 22:53:19

CREATE OR REPLACE FUNCTION sp_cargar_pago_energia_elec(
    p_id_energia integer,
    p_axo integer,
    p_periodo integer,
    p_fecha_pago date,
    p_oficina_pago integer,
    p_caja_pago varchar,
    p_operacion_pago integer,
    p_importe_pago numeric,
    p_cve_consumo varchar,
    p_cantidad numeric,
    p_folio varchar,
    p_id_usuario integer
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_11_pago_energia (
        id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    ) VALUES (
        DEFAULT, p_id_energia, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_cve_consumo, p_cantidad, p_folio, NOW(), p_id_usuario
    );
    DELETE FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;