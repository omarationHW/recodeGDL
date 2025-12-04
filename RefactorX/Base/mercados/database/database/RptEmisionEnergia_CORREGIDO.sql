-- ============================================
-- SP CORREGIDO: RptEmisionEnergia
-- Esquemas corregidos según postgreok.csv
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_rpt_emision_energia(p_oficina INTEGER, p_mercado INTEGER, p_axo INTEGER, p_periodo INTEGER)
RETURNS TABLE (
    id_energia INTEGER, datoslocal TEXT, nombre TEXT, descripcion TEXT, cuenta_energia INTEGER,
    local_adicional TEXT, cantidad NUMERIC, importe_energia NUMERIC, descripcion_consumo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_energia,
        CONCAT(a.oficina, ' ', a.num_mercado, ' ', a.categoria, ' ', a.seccion, ' ', a.local, ' ', COALESCE(a.letra_local, ''), ' ', COALESCE(a.bloque, '')) AS datoslocal,
        a.nombre, b.descripcion, b.cuenta_energia, d.local_adicional, d.cantidad,
        (d.cantidad * c.importe) AS importe_energia,
        CASE WHEN d.cve_consumo = 'F' THEN 'CONSUMO DE ENERGIA ELECTRICA' ELSE 'SERVICIO MEDIDO ENERGIA ELEC.' END AS descripcion_consumo
    FROM comun.ta_11_locales a
    JOIN comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN public.ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN public.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado AND a.vigencia = 'A' AND d.vigencia = 'E'
    GROUP BY d.id_energia, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.descripcion, b.cuenta_energia, d.local_adicional, d.cantidad, c.importe, d.cve_consumo;
END;
$$ LANGUAGE plpgsql;
