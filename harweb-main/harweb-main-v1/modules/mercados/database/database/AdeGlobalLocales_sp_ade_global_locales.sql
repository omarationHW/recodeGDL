-- Stored Procedure: sp_ade_global_locales
-- Tipo: Report
-- Descripción: Obtiene el listado de locales con adeudo global y accesorios para una recaudadora, mercado, año y mes.
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 20:19:25

CREATE OR REPLACE FUNCTION sp_ade_global_locales(
    p_rec integer,
    p_merc integer,
    p_axo integer,
    p_mes integer
)
RETURNS TABLE(
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local integer,
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    descripcion_local varchar,
    descripcion varchar(30),
    adeudo numeric,
    recargos numeric,
    multa numeric,
    gastos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_local,
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        a.descripcion_local,
        c.descripcion,
        SUM(b.importe) AS adeudo,
        SUM(ROUND((b.importe) * (
            SELECT COALESCE(SUM(porcentaje_mes),0) FROM ta_12_recargos WHERE (axo = b.axo AND mes >= b.periodo) OR (axo > b.axo)
        ) / 100, 2)) AS recargos,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_multa ELSE 0 END)
                  FROM ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS multa,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_gastos ELSE 0 END)
                  FROM ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS gastos
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.oficina = p_rec
      AND a.num_mercado = p_merc
      AND a.vigencia = 'A'
      AND ((b.axo = p_axo AND b.periodo <= p_mes) OR (b.axo < p_axo))
    GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local, c.descripcion
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;