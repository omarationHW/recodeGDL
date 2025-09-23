-- Stored Procedure: sp_get_cuota_energia
-- Tipo: Catalog
-- Descripción: Obtiene una cuota de energía eléctrica por ID.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06

CREATE OR REPLACE FUNCTION sp_get_cuota_energia(p_id_kilowhatts integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario
    FROM ta_11_kilowhatts
    WHERE id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;