-- Stored Procedure: sp_recargos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de recargo.
-- Generado para formulario: Recargos
-- Fecha: 2025-08-27 00:32:58

CREATE OR REPLACE FUNCTION sp_recargos_delete(
    p_axo SMALLINT,
    p_periodo SMALLINT
) RETURNS VOID AS $$
BEGIN
    DELETE FROM ta_11_recargos WHERE axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;