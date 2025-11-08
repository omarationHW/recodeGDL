-- Stored Procedure: sp_cuotas_energia_create
-- Tipo: CRUD
-- Descripción: Crea una nueva cuota de energía eléctrica.
-- Generado para formulario: CuotasEnergia
-- Fecha: 2025-08-26 23:31:39

CREATE OR REPLACE FUNCTION sp_cuotas_energia_create(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
) RETURNS TABLE (id_kilowhatts INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, NOW(), p_id_usuario)
    RETURNING id_kilowhatts INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;