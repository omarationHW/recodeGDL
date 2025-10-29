-- Stored Procedure: sp_insert_cuota_energia
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuota de energía eléctrica en ta_11_kilowhatts.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06

CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
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
    INSERT INTO ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    INTO id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;