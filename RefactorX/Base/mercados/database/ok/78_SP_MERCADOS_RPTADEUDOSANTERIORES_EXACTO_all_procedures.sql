-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptAdeudosAnteriores
-- Generado: 2025-08-27 00:39:09
-- Total SPs: 2
-- ============================================

-- SP 1/2: rpt_adeudos_anteriores
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos anteriores a 1996 para mercados, agrupando por local y año.
-- --------------------------------------------

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
            SELECT importe FROM public.ta_11_adeudo_local al
            WHERE al.id_local = c.id_local AND al.axo = p_axo
            ORDER BY al.periodo DESC LIMIT 1
        ) AS renta,
        (
            SELECT string_agg(CAST(periodo AS TEXT), ',') FROM public.ta_11_adeudo_local al
            WHERE al.id_local = c.id_local AND al.axo = a.axo AND al.periodo <= p_periodo
        ) AS meses,
        (
            CAST(c.oficina AS TEXT) || ' ' || CAST(c.num_mercado AS TEXT) || ' ' ||
            CAST(c.categoria AS TEXT) || ' ' || c.seccion || ' ' ||
            CAST(c.local AS TEXT) || ' ' || COALESCE(c.letra_local, '') || ' ' || COALESCE(c.bloque, '')
        ) AS datoslocal
    FROM public.ta_11_adeudo_local a
    JOIN public.ta_11_locales c ON a.id_local = c.id_local
    JOIN public.ta_12_recaudadoras d ON d.id_rec = c.oficina
    JOIN public.ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
    WHERE a.axo <= p_axo
      AND c.oficina = p_oficina
      AND a.periodo <= 12
      AND c.vigencia = 'A'
    GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, a.axo, c.clave_cuota, d.recaudadora, e.descripcion
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: rpt_mes_adeudo_ant
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo para un local y año específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_mes_adeudo_ant(p_id_local INTEGER, p_axo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe
    FROM public.ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo
    ORDER BY id_local, axo, periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

