-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptPadronGlobal
-- SP: sp_padron_global
-- Base: mercados.public
-- Fecha: 2025-12-03
-- ============================================

DROP FUNCTION IF EXISTS sp_padron_global(integer, integer, varchar);

CREATE OR REPLACE FUNCTION sp_padron_global(
    p_year integer,
    p_month integer,
    p_status varchar
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    descripcion_local varchar(50),
    superficie numeric,
    vigencia varchar(1),
    clave_cuota smallint,
    descripcion varchar(50),
    renta numeric,
    leyenda varchar(50),
    adeudo integer,
    registro varchar(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta
        CASE
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN l.superficie * c.importe_cuota
            WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
            WHEN l.num_mercado = 214 THEN (l.superficie * c.importe_cuota) * COALESCE(fd.sabadosacum, 1)
            ELSE l.superficie * c.importe_cuota
        END AS renta,
        -- Leyenda y adeudo
        CASE WHEN a.adeudos >= 1 THEN 'Local con Adeudo'::varchar(50) ELSE 'Local al Corriente de Pagos'::varchar(50) END AS leyenda,
        CASE WHEN a.adeudos >= 1 THEN 1 ELSE 0 END AS adeudo,
        -- Registro
        (l.oficina::text || ' ' || l.num_mercado::text || ' ' || l.categoria::text || ' ' || l.seccion || ' ' || l.local::text || ' ' || COALESCE(l.letra_local, '') || ' ' || COALESCE(l.bloque, ''))::varchar(100) AS registro
    FROM padron_licencias.comun.ta_11_locales l
    INNER JOIN padron_licencias.comun.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    INNER JOIN mercados.public.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND c.seccion = l.seccion
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT id_local, COUNT(*) AS adeudos
        FROM padron_licencias.comun.ta_11_adeudo_local
        WHERE (axo = p_year AND periodo <= p_month) OR (axo < p_year)
        GROUP BY id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN padron_licencias.comun.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY l.vigencia, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;
