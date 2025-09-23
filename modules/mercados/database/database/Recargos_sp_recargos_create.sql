-- Stored Procedure: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo.
-- Generado para formulario: Recargos
-- Fecha: 2025-08-27 00:32:58

CREATE OR REPLACE FUNCTION sp_recargos_create(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_porcentaje NUMERIC(8,2),
    p_usuario_id INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO ta_11_recargos(axo, periodo, porcentaje, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_porcentaje, NOW(), p_usuario_id);
END;
$$ LANGUAGE plpgsql;