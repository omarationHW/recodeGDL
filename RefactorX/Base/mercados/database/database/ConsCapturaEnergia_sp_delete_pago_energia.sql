-- Stored Procedure: sp_delete_pago_energia
-- Tipo: CRUD
-- Descripción: Elimina un pago de energía eléctrica y, si corresponde, restaura el adeudo
-- Generado para formulario: ConsCapturaEnergia
-- Fecha: 2025-08-26 23:12:09

CREATE OR REPLACE FUNCTION sp_delete_pago_energia(
    p_id_energia INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_usuario_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Eliminar el pago
    DELETE FROM ta_11_pago_energia
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
    RETURN 'Pago eliminado correctamente';
END;
$$ LANGUAGE plpgsql;