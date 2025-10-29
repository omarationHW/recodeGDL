-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Menu
-- Generado: 2025-08-27 00:15:05
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_adeudos_energia
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de energía eléctrica por oficina, mercado, año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_energia(
    p_oficina integer,
    p_mercado integer,
    p_axo integer,
    p_mes integer
) RETURNS TABLE(
    id_local integer,
    id_energia integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    local_adicional varchar,
    descripcion varchar,
    axo smallint,
    adeudo numeric,
    cuota numeric,
    mesesadeudos varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_local,
        f.id_energia,
        c.oficina,
        c.num_mercado,
        c.categoria,
        c.seccion,
        c.local,
        c.letra_local,
        c.bloque,
        c.nombre,
        f.local_adicional,
        d.descripcion,
        a.axo,
        SUM(a.importe) AS adeudo,
        0::numeric AS cuota, -- Se calcula en frontend o con otro SP
        NULL::varchar AS mesesadeudos -- Se calcula con otro SP
    FROM ta_11_adeudo_energ a
    JOIN ta_11_locales c ON a.id_energia = f.id_energia AND c.id_local = f.id_local
    JOIN ta_11_energia f ON a.id_energia = f.id_energia
    JOIN ta_11_mercados d ON c.oficina = d.oficina AND c.num_mercado = d.num_mercado_nvo
    WHERE a.axo = p_axo
      AND c.oficina = p_oficina
      AND c.num_mercado = p_mercado
      AND f.vigencia <> 'B'
    GROUP BY c.id_local, f.id_energia, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, f.local_adicional, d.descripcion, a.axo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_meses_adeudo_energia
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo de energía eléctrica para un id_energia y año/mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo_energia(
    p_id_energia integer,
    p_axo integer,
    p_mes integer
) RETURNS TABLE(
    periodo smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT periodo, importe
    FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia
      AND (axo = p_axo AND periodo <= p_mes)
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

