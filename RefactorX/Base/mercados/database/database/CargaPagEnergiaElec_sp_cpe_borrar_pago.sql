-- Stored Procedure: sp_cpe_borrar_pago
-- Tipo: CRUD
-- Descripción: Borra un pago de energía eléctrica y regresa el adeudo correspondiente
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 19:52:08

CREATE OR REPLACE FUNCTION sp_cpe_borrar_pago(
    p_id_energia INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_id_usuario INTEGER
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    pago RECORD;
BEGIN
    SELECT * INTO pago FROM ta_11_pago_energia WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
    IF NOT FOUND THEN
        RETURN QUERY SELECT 'Pago no encontrado';
        RETURN;
    END IF;
    INSERT INTO ta_11_adeudo_energ (
        id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, pago.id_energia, pago.axo, pago.periodo, pago.cve_consumo, pago.cantidad, pago.importe_pago, CURRENT_TIMESTAMP, p_id_usuario
    );
    DELETE FROM ta_11_pago_energia WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;