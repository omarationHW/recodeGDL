-- Stored Procedure: rpt_adeudos_anteriores
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos anteriores a 1996 para mercados, agrupando por local y año.
-- Generado para formulario: RptAdeudosAnteriores
-- Fecha: 2025-08-27 00:39:09

CREATE OR REPLACE FUNCTION rpt_adeudos_anteriores(p_axo INTEGER, p_oficina INTEGER, p_periodo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR,
    axo SMALLINT,
    totade INTEGER,
    clave_cuota SMALLINT,
    adeudo NUMERIC,
    recaudadora VARCHAR,
    descripcion VARCHAR,
    renta NUMERIC,
    meses TEXT,
    datoslocal TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id_local,
        c.oficina,
        c.num_mercado,
        c.categoria,
        c.seccion,
        c.local,
        c.letra_local,
        c.bloque,
        c.nombre,
        a.axo,
        1 AS totade,
        c.clave_cuota,
        SUM(a.importe) AS adeudo,
        UPPER(d.recaudadora) AS recaudadora,
        e.descripcion,
        (
            SELECT importe FROM publico.ta_11_adeudo_local al
            WHERE al.id_local = c.id_local AND al.axo = p_axo
            ORDER BY al.periodo DESC LIMIT 1
        ) AS renta,
        (
            SELECT string_agg(CAST(periodo AS TEXT), ',') FROM publico.ta_11_adeudo_local al
            WHERE al.id_local = c.id_local AND al.axo = a.axo AND al.periodo <= p_periodo
        ) AS meses,
        (
            CAST(c.oficina AS TEXT) || ' ' || CAST(c.num_mercado AS TEXT) || ' ' ||
            CAST(c.categoria AS TEXT) || ' ' || c.seccion || ' ' ||
            CAST(c.local AS TEXT) || ' ' || COALESCE(c.letra_local, '') || ' ' || COALESCE(c.bloque, '')
        ) AS datoslocal
    FROM publico.ta_11_adeudo_local a
    JOIN publico.ta_11_locales c ON a.id_local = c.id_local
    JOIN public.ta_12_recaudadoras d ON d.id_rec = c.oficina
    JOIN publico.ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
    WHERE a.axo <= p_axo
      AND c.oficina = p_oficina
      AND a.periodo <= 12
      AND c.vigencia = 'A'
    GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, a.axo, c.clave_cuota, d.recaudadora, e.descripcion
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo;
END;
$$ LANGUAGE plpgsql;