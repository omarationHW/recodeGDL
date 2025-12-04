-- ============================================
-- SP CORREGIDO: RptAdeudosLocales
-- Esquemas corregidos según postgreok.csv
-- ============================================

-- SP 1/3: sp_get_adeudos_locales
DROP FUNCTION IF EXISTS public.sp_get_adeudos_locales(integer, integer, integer);
CREATE OR REPLACE FUNCTION public.sp_get_adeudos_locales(p_axo integer, p_oficina integer, p_periodo integer)
RETURNS TABLE(
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    superficie float,
    clave_cuota smallint,
    adeudo numeric,
    recaudadora varchar,
    descripcion varchar,
    meses varchar,
    datoslocal varchar,
    renta_calc numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_local,
        c.oficina,
        c.num_mercado,
        c.categoria,
        c.seccion,
        c.letra_local,
        c.bloque,
        c.nombre,
        c.superficie,
        c.clave_cuota,
        SUM(a.importe) AS adeudo,
        UPPER(d.recaudadora) AS recaudadora,
        e.descripcion,
        (
            SELECT string_agg(CAST(periodo AS varchar), ',')
            FROM comun.ta_11_adeudo_local m
            WHERE m.id_local = c.id_local AND m.axo = p_axo AND m.periodo <= p_periodo
        ) AS meses,
        (
            c.oficina || ' ' || c.num_mercado || ' ' || c.categoria || ' ' || c.seccion || ' ' || c.local || ' ' || COALESCE(c.letra_local,'') || ' ' || COALESCE(c.bloque,'')
        ) AS datoslocal,
        (
            SELECT
                CASE
                    WHEN p_axo = EXTRACT(YEAR FROM CURRENT_DATE) THEN
                        CASE
                            WHEN c.seccion = 'PS' AND c.clave_cuota = 4 THEN c.superficie * cuo.importe_cuota
                            WHEN c.seccion = 'PS' THEN (cuo.importe_cuota * c.superficie) * 30
                            WHEN c.num_mercado = 214 THEN (c.superficie * cuo.importe_cuota) * fd.sabadosacum
                            ELSE c.superficie * cuo.importe_cuota
                        END
                    ELSE 0
                END
            FROM public.ta_11_cuo_locales cuo
            LEFT JOIN comun.ta_11_fecha_desc fd ON fd.mes = p_periodo
            WHERE cuo.axo = p_axo AND cuo.categoria = c.categoria AND cuo.seccion = c.seccion AND cuo.clave_cuota = c.clave_cuota
            LIMIT 1
        ) AS renta_calc
    FROM comun.ta_11_adeudo_local a
    JOIN comun.ta_11_locales c ON a.id_local = c.id_local
    JOIN comun.ta_12_recaudadoras d ON d.id_rec = c.oficina
    JOIN comun.ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
    WHERE a.axo = p_axo AND c.oficina = p_oficina AND a.periodo <= p_periodo AND c.vigencia = 'A'
    GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota, d.recaudadora, e.descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP 2/3: sp_get_meses_adeudo
CREATE OR REPLACE FUNCTION public.sp_get_meses_adeudo(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
    periodo smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT periodo, importe
    FROM comun.ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo <= p_periodo
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;

-- SP 3/3: sp_get_renta_local
CREATE OR REPLACE FUNCTION public.sp_get_renta_local(p_axo integer, p_categoria integer, p_seccion varchar, p_clave_cuota integer)
RETURNS TABLE(
    importe_cuota numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT importe_cuota
    FROM public.ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;
