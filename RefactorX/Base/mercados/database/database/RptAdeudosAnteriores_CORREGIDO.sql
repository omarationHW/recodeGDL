-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptAdeudosAnteriores
-- Base: mercados.public
-- Fecha: 2025-12-02
-- ============================================

DROP FUNCTION IF EXISTS rpt_adeudos_anteriores(integer, integer, integer);

CREATE OR REPLACE FUNCTION rpt_adeudos_anteriores(
    p_axo integer,
    p_oficina integer,
    p_periodo integer
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    axo smallint,
    totade integer,
    clave_cuota smallint,
    adeudo numeric,
    recaudadora varchar,
    descripcion varchar,
    renta numeric,
    meses text,
    datoslocal text
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
            SELECT importe FROM comun.ta_11_adeudo_local al
            WHERE al.id_local = c.id_local AND al.axo = p_axo
            ORDER BY al.periodo DESC LIMIT 1
        ) AS renta,
        (
            SELECT string_agg(CAST(periodo AS TEXT), ',') FROM comun.ta_11_adeudo_local al
            WHERE al.id_local = c.id_local AND al.axo = a.axo AND al.periodo <= p_periodo
        ) AS meses,
        (
            CAST(c.oficina AS TEXT) || ' ' || CAST(c.num_mercado AS TEXT) || ' ' ||
            CAST(c.categoria AS TEXT) || ' ' || c.seccion || ' ' ||
            CAST(c.local AS TEXT) || ' ' || COALESCE(c.letra_local, '') || ' ' || COALESCE(c.bloque, '')
        ) AS datoslocal
    FROM comun.ta_11_adeudo_local a
    INNER JOIN comun.ta_11_locales c ON a.id_local = c.id_local
    INNER JOIN comun.ta_12_recaudadoras d ON d.id_rec = c.oficina
    INNER JOIN comun.ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
    WHERE a.axo <= p_axo
      AND c.oficina = p_oficina
      AND a.periodo <= 12
      AND c.vigencia = 'A'
    GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, a.axo, c.clave_cuota, d.recaudadora, e.descripcion
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo;
END;
$$ LANGUAGE plpgsql;
