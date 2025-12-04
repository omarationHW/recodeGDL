-- Stored Procedure: sp_padron_global
-- Tipo: Report
-- Descripción: Obtiene el padrón global de locales con cálculo de renta y estatus de adeudo.
-- Generado para formulario: RptPadronGlobal
-- Fecha: 2025-08-27 01:26:10
-- Corregido: 2025-12-03 (tipos de datos y uso de TRIM para character fields)

CREATE OR REPLACE FUNCTION sp_padron_global(p_year integer, p_month integer, p_status varchar)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar,
    superficie numeric,
    vigencia varchar,
    clave_cuota smallint,
    descripcion varchar,
    renta numeric,
    leyenda varchar,
    adeudo integer,
    registro varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        TRIM(l.seccion)::varchar AS seccion,
        l.letra_local,
        l.bloque,
        l.nombre,
        TRIM(l.descripcion_local)::varchar AS descripcion_local,
        l.superficie,
        TRIM(l.vigencia)::varchar AS vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta
        CASE
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN (l.superficie * COALESCE(c.importe_cuota, 0))
            WHEN l.seccion = 'PS' THEN ((COALESCE(c.importe_cuota, 0) * l.superficie) * 30)
            WHEN l.num_mercado = 214 THEN ((l.superficie * COALESCE(c.importe_cuota, 0)) * COALESCE(fd.sabadosacum, 1))
            ELSE (l.superficie * COALESCE(c.importe_cuota, 0))
        END AS renta,
        -- Leyenda y adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::varchar
            ELSE 'Local al Corriente de Pagos'::varchar
        END AS leyenda,
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END AS adeudo,
        -- Registro
        (l.oficina::TEXT || ' ' || l.num_mercado::TEXT || ' ' || l.categoria::TEXT || ' ' ||
         TRIM(l.seccion) || ' ' || l.local::TEXT || ' ' || COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::varchar AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND TRIM(c.seccion) = TRIM(l.seccion)
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT ade.id_local, COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local ade
        WHERE (ade.axo = p_year AND ade.periodo <= p_month) OR (ade.axo < p_year)
        GROUP BY ade.id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE (p_status = 'T' OR TRIM(l.vigencia) = p_status)
    ORDER BY TRIM(l.vigencia), l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;