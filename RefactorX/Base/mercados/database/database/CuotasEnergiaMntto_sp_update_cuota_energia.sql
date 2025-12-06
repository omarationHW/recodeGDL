-- Stored Procedure: sp_update_cuota_energia
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de energía eléctrica existente.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06
-- Desplegado: 2025-12-03 (corregido con tipos smallint)

CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    UPDATE public.ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = CURRENT_TIMESTAMP,
        id_usuario = p_id_usuario
    WHERE ta_11_kilowhatts.id_kilowhatts = p_id_kilowhatts
      AND ta_11_kilowhatts.axo = p_axo
      AND ta_11_kilowhatts.periodo = p_periodo
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario;
END;
$$ LANGUAGE plpgsql;