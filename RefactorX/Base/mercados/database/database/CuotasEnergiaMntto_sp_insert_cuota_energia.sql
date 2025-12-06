-- Stored Procedure: sp_insert_cuota_energia
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuota de energía eléctrica en ta_11_kilowhatts.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06
-- Desplegado: 2025-12-03 (corregido con tipos smallint)

CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)
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
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario;
END;
$$ LANGUAGE plpgsql;