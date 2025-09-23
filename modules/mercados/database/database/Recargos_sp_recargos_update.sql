-- Stored Procedure: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente.
-- Generado para formulario: Recargos
-- Fecha: 2025-08-27 00:32:58

CREATE OR REPLACE FUNCTION sp_recargos_update(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_porcentaje NUMERIC(8,2),
    p_usuario_id INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_11_recargos
    SET porcentaje = p_porcentaje,
        fecha_alta = NOW(),
        id_usuario = p_usuario_id
    WHERE axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;