-- Stored Procedure: sp_delete_pago_energia
-- Tipo: CRUD
-- Descripción: Elimina un pago de energía eléctrica por id_pago_energia.
-- Generado para formulario: PagosEneCons
-- Fecha: 2025-08-27 00:23:09

CREATE OR REPLACE FUNCTION sp_delete_pago_energia(
    p_id_pago_energia INTEGER,
    p_id_usuario INTEGER
) RETURNS TABLE (
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM ta_11_pago_energia WHERE id_pago_energia = p_id_pago_energia;
    RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;