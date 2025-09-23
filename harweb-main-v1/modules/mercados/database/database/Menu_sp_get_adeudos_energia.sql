-- Stored Procedure: sp_get_adeudos_energia
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de energía eléctrica por oficina, mercado, año y mes.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 00:15:05

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