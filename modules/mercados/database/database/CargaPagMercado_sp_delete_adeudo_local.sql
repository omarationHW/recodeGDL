-- Stored Procedure: sp_delete_adeudo_local
-- Tipo: CRUD
-- Descripción: Elimina un adeudo local específico
-- Generado para formulario: CargaPagMercado
-- Fecha: 2025-08-26 22:58:28

CREATE OR REPLACE FUNCTION sp_delete_adeudo_local(
    p_id_local integer,
    p_axo smallint,
    p_periodo smallint
) RETURNS TABLE(status text, message text) AS $$
BEGIN
    DELETE FROM ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    RETURN QUERY SELECT 'OK', 'Adeudo eliminado';
END;
$$ LANGUAGE plpgsql;