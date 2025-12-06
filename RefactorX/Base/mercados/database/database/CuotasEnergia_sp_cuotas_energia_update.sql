-- Stored Procedure: sp_cuotas_energia_update
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de energía eléctrica existente.
-- Generado para formulario: CuotasEnergia
-- Fecha: 2025-08-26 23:31:39

CREATE OR REPLACE FUNCTION sp_cuotas_energia_update(
    p_id_kilowhatts INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE public.ta_11_kilowhatts
    SET axo = p_axo,
        periodo = p_periodo,
        importe = p_importe,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;