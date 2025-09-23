-- Stored Procedure: sp_cuotas_energia_delete
-- Tipo: CRUD
-- Descripción: Elimina una cuota de energía eléctrica.
-- Generado para formulario: CuotasEnergia
-- Fecha: 2025-08-26 23:31:39

CREATE OR REPLACE FUNCTION sp_cuotas_energia_delete(
    p_id_kilowhatts INTEGER
) RETURNS VOID AS $$
BEGIN
    DELETE FROM ta_11_kilowhatts WHERE id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;