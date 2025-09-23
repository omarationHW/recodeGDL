-- Stored Procedure: sp_adeudos_locales_list
-- Tipo: Report
-- Descripción: Lista los adeudos locales por año, oficina y periodo, incluyendo cálculo de meses de adeudo y renta.
-- Generado para formulario: AdeudosLocales
-- Fecha: 2025-08-26 20:22:20

CREATE OR REPLACE FUNCTION sp_adeudos_locales_list(p_year integer, p_oficina integer, p_periodo integer)
RETURNS TABLE(
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    superficie float,
    clave_cuota smallint,
    adeudo numeric,
    recaudadora varchar(50),
    descripcion varchar(30),
    meses varchar(26),
    datoslocal varchar(19),
    renta numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.letra_local, l.bloque, l.nombre, l.superficie, l.clave_cuota,
        SUM(a.importe) AS adeudo, r.recaudadora, m.descripcion,
        (
            SELECT string_agg(CAST(al.periodo AS varchar), ',')
            FROM ta_11_adeudo_local al
            WHERE al.id_local = l.id_local AND al.axo = p_year
        ) AS meses,
        CONCAT(l.oficina, ' ', l.num_mercado, ' ', l.categoria, ' ', l.seccion, ' ', l.local, ' ', COALESCE(l.letra_local, ''), ' ', COALESCE(l.bloque, '')) AS datoslocal,
        (
            SELECT CASE 
                WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN l.superficie * c.importe_cuota
                WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
                WHEN l.num_mercado = 214 THEN (l.superficie * c.importe_cuota) * fd.sabadosacum
                ELSE l.superficie * c.importe_cuota
            END
            FROM ta_11_cuo_locales c
            LEFT JOIN ta_11_fecha_desc fd ON fd.mes = p_periodo
            WHERE c.axo = p_year AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
            LIMIT 1
        ) AS renta
    FROM ta_11_adeudo_local a
    JOIN ta_11_locales l ON a.id_local = l.id_local
    JOIN ta_12_recaudadoras r ON l.oficina = r.id_rec
    JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    WHERE a.axo = p_year AND l.oficina = p_oficina AND a.periodo <= p_periodo AND l.vigencia = 'A'
    GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.letra_local, l.bloque, l.nombre, l.superficie, l.clave_cuota, r.recaudadora, m.descripcion, l.local
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;