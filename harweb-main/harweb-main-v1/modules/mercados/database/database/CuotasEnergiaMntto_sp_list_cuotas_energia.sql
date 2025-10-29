-- Stored Procedure: sp_list_cuotas_energia
-- Tipo: Catalog
-- Descripción: Lista cuotas de energía eléctrica, opcionalmente filtrando por año y/o periodo.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06

CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(p_axo integer DEFAULT NULL, p_periodo integer DEFAULT NULL)
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
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_periodo IS NULL OR periodo = p_periodo)
    ORDER BY axo DESC, periodo DESC;
END;
$$ LANGUAGE plpgsql;