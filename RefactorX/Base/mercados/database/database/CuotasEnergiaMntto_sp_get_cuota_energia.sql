-- Stored Procedure: sp_get_cuota_energia
-- Tipo: Catalog
-- Descripción: Obtiene una cuota de energía eléctrica por ID.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06
-- Desplegado: 2025-12-03 (corregido con tipos smallint)

CREATE OR REPLACE FUNCTION sp_get_cuota_energia(p_id_kilowhatts integer)
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
    SELECT k.id_kilowhatts, k.axo, k.periodo, k.importe, k.fecha_alta, k.id_usuario
    FROM public.ta_11_kilowhatts k
    WHERE k.id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;