-- Stored Procedure: get_ade_global_locales
-- Tipo: Report
-- Descripción: Obtiene el listado de locales con adeudo global y accesorios para una oficina, mercado, año y mes.
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 18:41:59

CREATE OR REPLACE FUNCTION get_ade_global_locales(
    p_oficina integer,
    p_mercado integer,
    p_anio integer,
    p_mes integer
)
RETURNS TABLE (
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
        a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local, c.descripcion,
        SUM(b.importe) AS adeudo,
        SUM(ROUND((b.importe) * (
            SELECT COALESCE(SUM(porcentaje_mes),0) FROM ta_12_recargos WHERE (axo=b.axo AND mes>=b.periodo) OR (axo>b.axo)
        ) / 100, 2)) AS recargos,
        COALESCE((SELECT SUM(importe_multa) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND vigencia='1' AND clave_practicado='P'),0) AS multa,
        COALESCE((SELECT SUM(importe_gastos) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND vigencia='1' AND clave_practicado='P'),0) AS gastos
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND ((b.axo = p_anio AND b.periodo <= p_mes) OR (b.axo < p_anio))
    GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local, c.descripcion;
END;
$$ LANGUAGE plpgsql;