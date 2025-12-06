-- Stored Procedure: sp_list_cuotas_energia
-- Tipo: Catalog
-- Descripción: Lista cuotas de energía eléctrica, opcionalmente filtrando por año y/o periodo.
-- Generado para formulario: CuotasEnergiaMntto
-- Fecha: 2025-08-26 23:33:06
-- Desplegado: 2025-12-03 (corregido con tipos smallint y JOIN con usuarios)

CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(p_axo smallint DEFAULT NULL, p_periodo smallint DEFAULT NULL)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo,
        k.periodo,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
$$ LANGUAGE plpgsql;