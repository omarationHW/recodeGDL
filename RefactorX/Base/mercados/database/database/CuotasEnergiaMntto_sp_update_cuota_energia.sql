-- Stored Procedure: sp_update_cuota_energia
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de energía eléctrica existente.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06

CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
DECLARE
BEGIN
    UPDATE ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = CURRENT_TIMESTAMP,
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts
      AND axo = p_axo
      AND periodo = p_periodo
    RETURNING id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    INTO id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;